# Functions (Funciones)

Esta carpeta contiene funciones de PostgreSQL/PL-pgSQL reutilizables.

## ¿Qué es una Función?

Las **funciones** son bloques de código SQL/PL-pgSQL que encapsulan lógica que puede ser:
- Reutilizada en múltiples lugares
- Invocada desde triggers
- Llamada desde consultas SQL
- Ejecutada desde la aplicación

## Funciones Disponibles

### update_updated_at_column()
Actualiza automáticamente el campo `updated_at` cuando se modifica un registro.

**Uso:**
```sql
CREATE TRIGGER update_tabla_updated_at
  BEFORE UPDATE ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Tipos de Funciones

### 1. Funciones de Trigger
Funciones que se ejecutan automáticamente por triggers.

```sql
-- functions/update_updated_at_column.sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2. Funciones de Validación
Funciones que validan datos antes de insertar/actualizar.

```sql
-- functions/validate_email.sql
CREATE OR REPLACE FUNCTION validate_email(email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### 3. Funciones de Cálculo
Funciones que realizan cálculos o transformaciones.

```sql
-- functions/calculate_retention_rate.sql
CREATE OR REPLACE FUNCTION calculate_retention_rate(
  start_date DATE,
  end_date DATE
)
RETURNS NUMERIC AS $$
DECLARE
  total_subscribers INTEGER;
  active_subscribers INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_subscribers
  FROM subscribers
  WHERE created_at BETWEEN start_date AND end_date;

  SELECT COUNT(*) INTO active_subscribers
  FROM subscribers
  WHERE created_at BETWEEN start_date AND end_date
    AND status = 'active';

  IF total_subscribers = 0 THEN
    RETURN 0;
  END IF;

  RETURN (active_subscribers::NUMERIC / total_subscribers * 100)::NUMERIC(5,2);
END;
$$ LANGUAGE plpgsql STABLE;
```

### 4. Funciones de Utilidad
Funciones auxiliares para tareas comunes.

```sql
-- functions/get_subscriber_count_by_country.sql
CREATE OR REPLACE FUNCTION get_subscriber_count_by_country(country_name TEXT)
RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)
    FROM subscribers
    WHERE country = country_name
      AND status = 'active'
  );
END;
$$ LANGUAGE plpgsql STABLE;
```

## Plantilla de Función

```sql
-- ============================================================================
-- Function: nombre_funcion
-- Description: [Qué hace la función y cuándo usarla]
-- Parameters:
--   - param1 (tipo): Descripción del parámetro
--   - param2 (tipo): Descripción del parámetro
-- Returns: tipo_retorno - Descripción de lo que retorna
-- Author: AltoQ Team
-- Date: YYYY-MM-DD
-- ============================================================================

-- ============================================================================
-- Usage:
-- ============================================================================
-- SELECT nombre_funcion(valor1, valor2);
--
-- Ejemplo:
-- SELECT calculate_conversion_rate('2024-01-01', '2024-12-31');

-- ============================================================================
-- Dependencies:
-- ============================================================================
-- - Requiere: tabla1, tabla2
-- - Usado por: trigger X, vista Y

-- ============================================================================
-- Function Definition
-- ============================================================================

CREATE OR REPLACE FUNCTION nombre_funcion(
  param1 tipo1,
  param2 tipo2
)
RETURNS tipo_retorno AS $$
DECLARE
  -- Variables locales
  var1 tipo;
BEGIN
  -- Lógica de la función
  RETURN resultado;
END;
$$ LANGUAGE plpgsql STABLE;

-- O para funciones SQL simples:
-- $$ LANGUAGE sql IMMUTABLE;

-- ============================================================================
-- Comentarios para documentación
-- ============================================================================

COMMENT ON FUNCTION nombre_funcion(tipo1, tipo2) IS
  'Descripción detallada de qué hace la función, parámetros y valor de retorno';

-- ============================================================================
-- Tests
-- ============================================================================

-- Test 1: Caso normal
-- SELECT nombre_funcion(valor1, valor2);
-- Resultado esperado: ...

-- Test 2: Caso edge
-- SELECT nombre_funcion(NULL, valor2);
-- Resultado esperado: ...
```

## Clasificación de Funciones por VOLATILIDAD

PostgreSQL clasifica funciones según su volatilidad:

### IMMUTABLE
- El resultado NUNCA cambia para los mismos inputs
- No lee de la base de datos
- Ejemplo: cálculos matemáticos puros, validaciones de formato

```sql
$$ LANGUAGE plpgsql IMMUTABLE;
```

### STABLE
- El resultado NO cambia dentro de una transacción
- Puede leer de la base de datos
- Ejemplo: funciones que consultan tablas

```sql
$$ LANGUAGE plpgsql STABLE;
```

### VOLATILE (default)
- El resultado PUEDE cambiar en cualquier momento
- Puede modificar la base de datos
- Ejemplo: funciones que usan NOW(), RANDOM(), o hacen INSERT/UPDATE

```sql
$$ LANGUAGE plpgsql VOLATILE;
```

## Gestión de Funciones

### Crear o Reemplazar
```sql
CREATE OR REPLACE FUNCTION mi_funcion() ...
```

### Eliminar
```sql
DROP FUNCTION IF EXISTS mi_funcion(param_types);
```

### Ver Definición
```sql
SELECT pg_get_functiondef('mi_funcion'::regproc);
```

### Listar Funciones
```sql
SELECT proname, prosrc FROM pg_proc
WHERE proname LIKE 'mi_funcion%';
```

## Mejores Prácticas

1. **Nombres Descriptivos**: Usa verbos que describan la acción
   - ✅ `calculate_retention_rate()`
   - ✅ `validate_email()`
   - ❌ `func1()`

2. **Documentación**: Siempre documenta parámetros y retorno

3. **Manejo de Errores**: Usa `RAISE EXCEPTION` para errores
   ```sql
   IF param IS NULL THEN
     RAISE EXCEPTION 'El parámetro no puede ser NULL';
   END IF;
   ```

4. **Performance**:
   - Declara volatilidad correcta (IMMUTABLE/STABLE)
   - Evita loops innecesarios
   - Usa índices apropiadamente

5. **Testing**: Incluye casos de prueba en los comentarios

6. **Reutilización**: Prefiere funciones pequeñas y enfocadas

## Ejemplos Comunes

### Función de Trigger para Timestamp
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Función de Validación
```sql
CREATE OR REPLACE FUNCTION is_valid_status(status TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN status IN ('active', 'unsubscribed');
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### Función de Agregación
```sql
CREATE OR REPLACE FUNCTION get_subscriber_stats(campaign TEXT)
RETURNS TABLE(
  total INTEGER,
  active INTEGER,
  unsubscribed INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::INTEGER,
    COUNT(CASE WHEN status = 'active' THEN 1 END)::INTEGER,
    COUNT(CASE WHEN status = 'unsubscribed' THEN 1 END)::INTEGER
  FROM subscribers
  WHERE utm_campaign = campaign;
END;
$$ LANGUAGE plpgsql STABLE;
```

---

Para más información, consulta el [README principal](../README.md).