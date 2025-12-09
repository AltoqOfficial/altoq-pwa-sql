# Seeds

Esta carpeta contiene scripts SQL para poblar la base de datos con datos iniciales o de prueba.

## Propósito

Los **seeds** (semillas) son datos que se insertan en la base de datos para:
- Datos de configuración inicial
- Datos de prueba para desarrollo
- Datos de ejemplo para demos
- Valores por defecto del sistema

## Cuándo Usar Seeds

### ✅ Usar seeds para:
- Roles y permisos predefinidos
- Categorías o tipos predeterminados
- Datos de configuración del sistema
- Datos de prueba para desarrollo local
- Datos de ejemplo para documentación

### ❌ NO usar seeds para:
- Datos de producción reales
- Información de usuarios reales
- Datos sensibles o privados
- Datos que cambiarán frecuentemente

## Estructura de Archivos

Nombra los archivos descriptivamente:

```
seeds/
├── dev_subscribers.sql          # Datos de prueba para desarrollo
├── sample_analytics_data.sql    # Datos de ejemplo para reportes
└── test_utm_campaigns.sql       # Datos de prueba de campañas
```

## Ejemplo de Seed

```sql
-- ============================================================================
-- Seed: dev_subscribers
-- Description: Datos de prueba de suscriptores para ambiente de desarrollo
-- Author: AltoQ Team
-- Date: 2025-12-08
-- Environment: DEVELOPMENT ONLY
-- ============================================================================

-- ADVERTENCIA: NO ejecutar en producción
-- Este script es solo para ambientes de desarrollo y testing

INSERT INTO subscribers (
  email,
  status,
  terms_accepted,
  device_type,
  country,
  utm_source,
  utm_campaign
) VALUES
  ('test1@example.com', 'active', true, 'desktop', 'Peru', 'google', 'test-campaign'),
  ('test2@example.com', 'active', true, 'mobile', 'Mexico', 'facebook', 'test-campaign'),
  ('test3@example.com', 'unsubscribed', true, 'tablet', 'Colombia', 'instagram', 'test-campaign')
ON CONFLICT (email) DO NOTHING;
```

## Ejecución de Seeds

### Desarrollo Local

```bash
# Ejecutar seed específico
psql "$DATABASE_URL" -f seeds/dev_subscribers.sql

# Ejecutar todos los seeds
for file in seeds/*.sql; do
  psql "$DATABASE_URL" -f "$file"
done
```

### Con Scripts de Utilidad

```bash
# Usando script personalizado
./scripts/run_seeds.sh
```

## Mejores Prácticas

1. **Idempotencia**: Usa `ON CONFLICT DO NOTHING` o `INSERT ... WHERE NOT EXISTS`
2. **Documentación**: Incluye header con propósito y ambiente
3. **Ambiente**: Marca claramente si es solo para dev/test
4. **Limpieza**: Proporciona script para limpiar los datos de prueba
5. **Versionado**: Versiona los seeds junto con las migraciones

## Limpieza de Seeds

Crea un archivo de limpieza para remover datos de prueba:

```sql
-- seeds/cleanup_dev_data.sql
DELETE FROM subscribers WHERE email LIKE 'test%@example.com';
```

---

Para más información, consulta el [README principal](../README.md).