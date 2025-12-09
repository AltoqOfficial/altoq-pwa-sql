-- ============================================================================
-- Migration: [NÚMERO]_[DESCRIPCIÓN]
-- Description: [Describe qué hace esta migración y por qué es necesaria]
-- Author: [Tu nombre]
-- Date: [YYYY-MM-DD]
-- ============================================================================

-- ============================================================================
-- IMPORTANTE: Antes de ejecutar
-- ============================================================================
-- [ ] Haz backup de la base de datos
-- [ ] Prueba en desarrollo/staging primero
-- [ ] Revisa el script de rollback correspondiente
-- [ ] Actualiza CHANGELOG.md con los cambios

-- ============================================================================
-- Cambios principales
-- ============================================================================
-- 1. [Describe cambio 1]
-- 2. [Describe cambio 2]
-- 3. [Describe cambio 3]

-- ============================================================================
-- BEGIN MIGRATION
-- ============================================================================

-- Ejemplo: Crear nueva tabla
-- CREATE TABLE IF NOT EXISTS nombre_tabla (
--   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
--   campo_texto TEXT NOT NULL,
--   campo_numero INTEGER DEFAULT 0,
--   created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
--   updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
-- );

-- Ejemplo: Agregar columna a tabla existente
-- ALTER TABLE tabla_existente
-- ADD COLUMN nueva_columna TEXT;

-- Ejemplo: Crear índice
-- CREATE INDEX IF NOT EXISTS idx_tabla_columna
-- ON nombre_tabla(columna);

-- Ejemplo: Crear función
-- CREATE OR REPLACE FUNCTION nombre_funcion()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   -- Lógica de la función
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- Ejemplo: Crear trigger
-- CREATE TRIGGER nombre_trigger
--   BEFORE UPDATE ON nombre_tabla
--   FOR EACH ROW
--   EXECUTE FUNCTION nombre_funcion();

-- Ejemplo: Agregar comentarios
-- COMMENT ON TABLE nombre_tabla IS 'Descripción de la tabla';
-- COMMENT ON COLUMN nombre_tabla.columna IS 'Descripción de la columna';

-- Ejemplo: Configurar Row Level Security
-- ALTER TABLE nombre_tabla ENABLE ROW LEVEL SECURITY;
--
-- CREATE POLICY "nombre_policy"
--   ON nombre_tabla
--   FOR SELECT
--   USING (true);

-- ============================================================================
-- Migración de datos (si es necesario)
-- ============================================================================

-- UPDATE tabla SET columna = valor WHERE condicion;

-- ============================================================================
-- END MIGRATION
-- ============================================================================

-- ============================================================================
-- Verificación post-migración
-- ============================================================================

-- SELECT * FROM nombre_tabla LIMIT 1;
-- SELECT COUNT(*) FROM nombre_tabla;

-- ============================================================================
-- Notas adicionales
-- ============================================================================
--
-- [Agrega cualquier nota importante, advertencia o consideración especial]
-- [Documenta dependencias con otras migraciones]
-- [Menciona si hay impacto en el rendimiento]
--