-- ============================================================================
-- Migration: 001_initial_subscribers_table
-- Description: Creación inicial de la tabla subscribers para almacenar
--              suscriptores con metadata completa para análisis de marketing
-- Author: Tadeo Portillo
-- Date: 2025-12-08
-- ============================================================================

-- ============================================================================
-- IMPORTANTE: Antes de ejecutar
-- ============================================================================
-- [x] Haz backup de la base de datos
-- [x] Prueba en desarrollo/staging primero
-- [x] Revisa el script de rollback correspondiente (rollbacks/rollback_001.sql)
-- [x] Actualiza CHANGELOG.md con los cambios

-- ============================================================================
-- Cambios principales
-- ============================================================================
-- 1. Crear tabla subscribers con campos de identificación, timestamps y estado
-- 2. Agregar campos de metadata del dispositivo (device_type, os, browser, etc.)
-- 3. Agregar campos de localización (timezone, language, ip, country, city)
-- 4. Agregar campos de tracking UTM (source, medium, campaign, referrer)
-- 5. Crear índices para optimizar consultas frecuentes
-- 6. Agregar comentarios de documentación en todas las columnas
-- 7. Configurar RLS (deshabilitado con justificación)

-- ============================================================================
-- Dependencies:
-- ============================================================================
-- - Requiere: functions/update_updated_at_column.sql (para el trigger)
-- - Requiere: PostgreSQL 12+ (para gen_random_uuid())
-- - Ejecutar después de esta migración:
--   * triggers/update_subscribers_updated_at.sql
--   * policies/subscribers_rls_disabled.sql

-- ============================================================================
-- BEGIN MIGRATION
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Crear tabla subscribers
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS subscribers (
  -- Identificación
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Estado
  status TEXT DEFAULT 'active' NOT NULL CHECK (status IN ('active', 'unsubscribed')),

  -- Consentimiento legal
  terms_accepted BOOLEAN DEFAULT false NOT NULL,
  terms_accepted_at TIMESTAMPTZ,

  -- Información del dispositivo
  device_type TEXT, -- mobile, tablet, desktop
  os TEXT, -- Windows, macOS, Android, iOS, Linux
  browser TEXT, -- Chrome, Firefox, Safari, Edge
  browser_version TEXT, -- 120.0.6099.109
  user_agent TEXT, -- User agent completo

  -- Información de pantalla
  screen_width INTEGER,
  screen_height INTEGER,

  -- Información de localización
  timezone TEXT, -- America/Lima
  language TEXT, -- es-PE, en-US

  -- Información de origen
  referrer TEXT, -- De dónde vino el usuario
  utm_source TEXT, -- facebook, google, instagram
  utm_medium TEXT, -- cpc, organic, social
  utm_campaign TEXT, -- lanzamiento-2025

  -- Información de red (opcional)
  ip_address TEXT,
  country TEXT, -- Peru, Mexico
  city TEXT -- Lima, Arequipa
);

-- ----------------------------------------------------------------------------
-- 2. Crear índices para optimización
-- ----------------------------------------------------------------------------

-- Índice para búsquedas por email (usado en validación de duplicados)
CREATE INDEX IF NOT EXISTS idx_subscribers_email
ON subscribers(email);

-- Índice para ordenar por fecha de creación (reportes cronológicos)
CREATE INDEX IF NOT EXISTS idx_subscribers_created_at
ON subscribers(created_at DESC);

-- Índice para filtrar por estado (consultas de activos/inactivos)
CREATE INDEX IF NOT EXISTS idx_subscribers_status
ON subscribers(status);

-- Índice para análisis por tipo de dispositivo
CREATE INDEX IF NOT EXISTS idx_subscribers_device_type
ON subscribers(device_type);

-- Índice para análisis geográfico
CREATE INDEX IF NOT EXISTS idx_subscribers_country
ON subscribers(country);

CREATE INDEX IF NOT EXISTS idx_subscribers_terms_accepted
ON subscribers(terms_accepted);

-- ----------------------------------------------------------------------------
-- 3. Agregar comentarios de documentación
-- ----------------------------------------------------------------------------

COMMENT ON TABLE subscribers IS
  'Tabla de suscriptores con metadata completa para análisis de marketing y seguimiento de conversiones';

-- Comentarios de identificación
COMMENT ON COLUMN subscribers.id IS
  'Identificador único del suscriptor (UUID generado automáticamente)';
COMMENT ON COLUMN subscribers.email IS
  'Email único del suscriptor (requerido)';

-- Comentarios de timestamps
COMMENT ON COLUMN subscribers.created_at IS
  'Fecha y hora de creación del registro';
COMMENT ON COLUMN subscribers.updated_at IS
  'Fecha y hora de última actualización del registro (se actualiza automáticamente)';

-- Comentarios de estado
COMMENT ON COLUMN subscribers.status IS
  'Estado del suscriptor: active (activo) o unsubscribed (dado de baja)';

-- Comentarios de consentimiento legal
COMMENT ON COLUMN subscribers.terms_accepted IS
  'Indica si el usuario aceptó los términos y condiciones al suscribirse (requerido para cumplimiento legal)';
COMMENT ON COLUMN subscribers.terms_accepted_at IS
  'Fecha y hora en que el usuario aceptó los términos (guardada solo si terms_accepted es true)';

-- Comentarios de información del dispositivo
COMMENT ON COLUMN subscribers.device_type IS
  'Tipo de dispositivo: mobile (móvil), tablet (tableta) o desktop (escritorio)';
COMMENT ON COLUMN subscribers.os IS
  'Sistema operativo del usuario (ej: Windows 10, Android 13, iOS 16, macOS)';
COMMENT ON COLUMN subscribers.browser IS
  'Navegador web utilizado (ej: Chrome, Firefox, Safari, Edge)';
COMMENT ON COLUMN subscribers.browser_version IS
  'Versión específica del navegador (ej: 120.0.6099.109)';
COMMENT ON COLUMN subscribers.user_agent IS
  'Cadena User Agent completa del navegador para análisis detallado';

-- Comentarios de información de pantalla
COMMENT ON COLUMN subscribers.screen_width IS
  'Ancho de la pantalla del dispositivo en píxeles';
COMMENT ON COLUMN subscribers.screen_height IS
  'Alto de la pantalla del dispositivo en píxeles';

-- Comentarios de información de localización
COMMENT ON COLUMN subscribers.timezone IS
  'Zona horaria del usuario (ej: America/Lima, America/New_York)';
COMMENT ON COLUMN subscribers.language IS
  'Idioma configurado en el navegador (ej: es-PE, en-US, pt-BR)';

-- Comentarios de información de origen
COMMENT ON COLUMN subscribers.referrer IS
  'URL de origen desde donde llegó el usuario (ej: https://facebook.com, https://google.com)';
COMMENT ON COLUMN subscribers.utm_source IS
  'Fuente de tráfico UTM para tracking de campañas (ej: facebook, google, instagram)';
COMMENT ON COLUMN subscribers.utm_medium IS
  'Medio de tráfico UTM (ej: cpc, organic, social, email)';
COMMENT ON COLUMN subscribers.utm_campaign IS
  'Nombre de la campaña UTM (ej: lanzamiento-2025, black-friday)';

-- Comentarios de información de red
COMMENT ON COLUMN subscribers.ip_address IS
  'Dirección IP del usuario en el momento de la suscripción';
COMMENT ON COLUMN subscribers.country IS
  'País del usuario detectado por IP o navegador (ej: Peru, Mexico, Colombia)';
COMMENT ON COLUMN subscribers.city IS
  'Ciudad del usuario detectada por IP (ej: Lima, Arequipa, Ciudad de México)';

-- ============================================================================
-- END MIGRATION
-- ============================================================================

-- ============================================================================
-- Verificación post-migración
-- ============================================================================

-- Verificar que la tabla existe
SELECT tablename FROM pg_tables WHERE tablename = 'subscribers';

-- Verificar estructura de columnas
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'subscribers'
ORDER BY ordinal_position;

-- Verificar índices creados
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'subscribers';

-- ============================================================================
-- Notas adicionales
-- ============================================================================
--
-- ORDEN DE EJECUCIÓN:
-- 1. Este archivo (001_initial_subscribers_table.sql)
-- 2. functions/update_updated_at_column.sql
-- 3. triggers/update_subscribers_updated_at.sql
-- 4. policies/subscribers_rls_disabled.sql
--
-- PERFORMANCE:
-- - Los índices están optimizados para consultas comunes
-- - La tabla está diseñada para ~100K-1M registros sin problemas
-- - Para volúmenes mayores, considerar particionamiento por fecha
--
-- SEGURIDAD:
-- - RLS deshabilitado intencionalmente (ver policies/subscribers_rls_disabled.sql)
-- - Validación de datos manejada en capa de aplicación
-- - Email tiene constraint UNIQUE para prevenir duplicados
--
-- CUMPLIMIENTO LEGAL:
-- - Campo terms_accepted requerido para GDPR/LGPD compliance
-- - Almacenamiento de IP puede requerir disclosure en Privacy Policy
--
-- ============================================================================