# Views (Vistas)

Esta carpeta contiene definiciones de vistas de la base de datos.

## ¿Qué es una Vista?

Una **vista** es una consulta SQL guardada que actúa como una tabla virtual. Las vistas:
- Simplifican consultas complejas
- Encapsulan lógica de negocio
- Mejoran la seguridad ocultando columnas sensibles
- Facilitan el acceso a datos agregados

## Cuándo Crear Vistas

### ✅ Crear vistas para:
- Consultas complejas usadas frecuentemente
- Joins entre múltiples tablas
- Agregaciones y cálculos repetitivos
- Filtros de seguridad o privacidad
- Reportes y dashboards

### ❌ Evitar vistas para:
- Consultas simples de una sola tabla
- Datos que necesitan actualizarse frecuentemente (considera materialized views)
- Operaciones que requieren índices específicos

## Tipos de Vistas

### Vista Simple
```sql
-- views/active_subscribers.sql
CREATE OR REPLACE VIEW active_subscribers AS
SELECT
  id,
  email,
  created_at,
  country,
  utm_source
FROM subscribers
WHERE status = 'active';
```

### Vista con Agregación
```sql
-- views/subscribers_by_country.sql
CREATE OR REPLACE VIEW subscribers_by_country AS
SELECT
  country,
  COUNT(*) as total_subscribers,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as active_count,
  COUNT(CASE WHEN status = 'unsubscribed' THEN 1 END) as unsubscribed_count
FROM subscribers
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_subscribers DESC;
```

### Vista Materializada (para performance)
```sql
-- views/materialized_campaign_stats.sql
CREATE MATERIALIZED VIEW IF NOT EXISTS campaign_stats AS
SELECT
  utm_campaign,
  utm_source,
  COUNT(*) as total_subscribers,
  COUNT(CASE WHEN device_type = 'mobile' THEN 1 END) as mobile_count,
  COUNT(CASE WHEN device_type = 'desktop' THEN 1 END) as desktop_count
FROM subscribers
WHERE utm_campaign IS NOT NULL
GROUP BY utm_campaign, utm_source;

-- Crear índice en vista materializada
CREATE UNIQUE INDEX idx_campaign_stats ON campaign_stats(utm_campaign, utm_source);

-- Para refrescar la vista:
-- REFRESH MATERIALIZED VIEW campaign_stats;
```

## Estructura de Archivos

```
views/
├── active_subscribers.sql
├── subscribers_by_country.sql
├── subscribers_by_device.sql
└── materialized_campaign_stats.sql
```

## Plantilla de Vista

```sql
-- ============================================================================
-- View: nombre_vista
-- Description: [Qué información proporciona esta vista y por qué es útil]
-- Tables: [Tablas involucradas]
-- Author: AltoQ Team
-- Date: YYYY-MM-DD
-- ============================================================================

-- ============================================================================
-- Dependencies:
-- ============================================================================
-- - Requiere: tabla1, tabla2
-- - Usado por: dashboard X, reporte Y

-- ============================================================================
-- View Definition
-- ============================================================================

CREATE OR REPLACE VIEW nombre_vista AS
SELECT
  -- Columnas seleccionadas con alias claros
  t1.id,
  t1.campo1,
  t2.campo2
FROM tabla1 t1
LEFT JOIN tabla2 t2 ON t1.id = t2.tabla1_id
WHERE condicion;

-- ============================================================================
-- Documentación
-- ============================================================================

COMMENT ON VIEW nombre_vista IS
  'Descripción detallada de qué muestra esta vista y casos de uso';

-- ============================================================================
-- Ejemplos de uso
-- ============================================================================

-- SELECT * FROM nombre_vista WHERE condicion;
-- SELECT COUNT(*) FROM nombre_vista;
```

## Gestión de Vistas

### Crear o Actualizar
```sql
CREATE OR REPLACE VIEW mi_vista AS ...
```

### Eliminar
```sql
DROP VIEW IF EXISTS mi_vista;
```

### Ver Definición
```sql
SELECT definition FROM pg_views WHERE viewname = 'mi_vista';
```

### Listar Todas las Vistas
```sql
SELECT schemaname, viewname FROM pg_views
WHERE schemaname = 'public';
```

## Vistas Materializadas

Las vistas materializadas almacenan los resultados físicamente (como una tabla):

**Ventajas:**
- Mucho más rápidas para consultas complejas
- Se pueden indexar

**Desventajas:**
- Ocupan espacio en disco
- Necesitan refrescarse manualmente o con cron
- No se actualizan automáticamente

```sql
-- Refrescar vista materializada
REFRESH MATERIALIZED VIEW nombre_vista;

-- Refrescar sin bloquear lecturas
REFRESH MATERIALIZED VIEW CONCURRENTLY nombre_vista;
```

## Mejores Prácticas

1. **Nombres Descriptivos**: Usa nombres que describan claramente qué contiene la vista
2. **Documentación**: Siempre incluye comentarios explicando el propósito
3. **Simplicidad**: Mantén las vistas simples y enfocadas
4. **Performance**: Para consultas pesadas, considera vistas materializadas
5. **Seguridad**: Usa vistas para ocultar columnas sensibles
6. **Versionado**: Versiona las vistas junto con las migraciones

## Ejemplos de Casos de Uso

### Dashboard de Suscriptores
```sql
CREATE OR REPLACE VIEW dashboard_stats AS
SELECT
  COUNT(*) as total,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as active,
  COUNT(CASE WHEN created_at >= NOW() - INTERVAL '7 days' THEN 1 END) as last_week,
  COUNT(CASE WHEN created_at >= NOW() - INTERVAL '30 days' THEN 1 END) as last_month
FROM subscribers;
```

### Análisis de UTM
```sql
CREATE OR REPLACE VIEW utm_performance AS
SELECT
  utm_source,
  utm_medium,
  utm_campaign,
  COUNT(*) as conversions,
  COUNT(CASE WHEN status = 'active' THEN 1 END) as active_subscribers
FROM subscribers
WHERE utm_source IS NOT NULL
GROUP BY utm_source, utm_medium, utm_campaign
ORDER BY conversions DESC;
```

---

Para más información, consulta el [README principal](../README.md).