# Changelog

Todos los cambios notables en la base de datos del proyecto altoq-pwa serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

### Próximos cambios planificados
- Ninguno por el momento

---

## [1.0.0] - 2025-12-08

### Added
- Tabla `subscribers` con campos completos para almacenar información de suscriptores
- Campos de metadata del dispositivo (device_type, os, browser, browser_version, user_agent)
- Campos de información de pantalla (screen_width, screen_height)
- Campos de localización (timezone, language, ip_address, country, city)
- Campos de tracking UTM (utm_source, utm_medium, utm_campaign, referrer)
- Campos de consentimiento legal (terms_accepted, terms_accepted_at)
- Sistema de timestamps automáticos (created_at, updated_at)
- Función `update_updated_at_column()` para actualizar automáticamente el campo updated_at
- Trigger `update_subscribers_updated_at` que actualiza updated_at en cada modificación
- Índices optimizados para mejorar rendimiento:
  - `idx_subscribers_email` - Para búsquedas por email
  - `idx_subscribers_created_at` - Para ordenar por fecha de creación
  - `idx_subscribers_status` - Para filtrar por estado
  - `idx_subscribers_device_type` - Para análisis por tipo de dispositivo
  - `idx_subscribers_country` - Para análisis geográfico
- Comentarios detallados en tabla y columnas para documentación
- Row Level Security deshabilitado con justificación documentada

### Security
- RLS deshabilitado intencionalmente para permitir inserts públicos
- Validación y sanitización manejada a nivel de API
- API keys protegidas en variables de entorno

---

## Formato de Entradas

### Added
Para nuevas funcionalidades, tablas, columnas, índices, etc.

### Changed
Para cambios en funcionalidades existentes.

### Deprecated
Para funcionalidades que serán removidas en versiones futuras.

### Removed
Para funcionalidades removidas.

### Fixed
Para correcciones de bugs.

### Security
Para cambios relacionados con seguridad.

---

**Nota:** Siempre incluye la fecha en formato YYYY-MM-DD y una descripción clara del cambio.