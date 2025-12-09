# Triggers (Disparadores)

Esta carpeta contiene definiciones de triggers de la base de datos.

## ¿Qué es un Trigger?

Un **trigger** (disparador) es código que se ejecuta automáticamente cuando ocurre un evento en la base de datos:
- INSERT (antes o después de insertar)
- UPDATE (antes o después de actualizar)
- DELETE (antes o después de eliminar)

## Triggers Disponibles

### update_subscribers_updated_at
Actualiza automáticamente el campo `updated_at` cuando se modifica un registro en la tabla `subscribers`.

**Evento:** BEFORE UPDATE
**Función:** `update_updated_at_column()`

## Tipos de Triggers

### 1. BEFORE Triggers
Se ejecutan ANTES de que ocurra el cambio. Pueden:
- Modificar los datos antes de guardarlos (cambiar NEW)
- Prevenir la operación (RETURN NULL)
- Validar datos

```sql
-- triggers/validate_email_before_insert.sql
CREATE TRIGGER validate_email_before_insert
  BEFORE INSERT ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION validate_subscriber_email();
```

### 2. AFTER Triggers
Se ejecutan DESPUÉS de que ocurrió el cambio. Útiles para:
- Logging y auditoría
- Sincronización con otras tablas
- Notificaciones

```sql
-- triggers/log_subscriber_changes.sql
CREATE TRIGGER log_subscriber_changes
  AFTER UPDATE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION log_change_to_audit_table();
```

### 3. INSTEAD OF Triggers
Reemplazan la operación original (solo para vistas).

```sql
CREATE TRIGGER update_view_instead
  INSTEAD OF UPDATE ON nombre_vista
  FOR EACH ROW
  EXECUTE FUNCTION handle_view_update();
```

## Plantilla de Trigger

```sql
-- ============================================================================
-- Trigger: nombre_trigger
-- Description: [Qué hace el trigger y por qué es necesario]
-- Table: nombre_tabla
-- Event: BEFORE/AFTER INSERT/UPDATE/DELETE
-- Author: AltoQ Team
-- Date: YYYY-MM-DD
-- ============================================================================

-- ============================================================================
-- Dependencies:
-- ============================================================================
-- Requiere: functions/nombre_funcion.sql
-- Requiere: tabla nombre_tabla existente

-- ============================================================================
-- Trigger Definition
-- ============================================================================

CREATE TRIGGER nombre_trigger
  BEFORE/AFTER INSERT/UPDATE/DELETE ON nombre_tabla
  FOR EACH ROW
  EXECUTE FUNCTION nombre_funcion();

-- ============================================================================
-- Verificación
-- ============================================================================
-- Para verificar que el trigger funciona:
--
-- INSERT INTO nombre_tabla (...) VALUES (...);
-- SELECT * FROM nombre_tabla WHERE ...;

-- ============================================================================
-- Notas
-- ============================================================================
-- [Comportamiento especial, consideraciones de performance, etc.]
```

## Eventos de Trigger

### INSERT
```sql
CREATE TRIGGER trigger_nombre
  BEFORE INSERT ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION funcion();
```

### UPDATE
```sql
CREATE TRIGGER trigger_nombre
  BEFORE UPDATE ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION funcion();
```

### UPDATE de columnas específicas
```sql
CREATE TRIGGER trigger_nombre
  BEFORE UPDATE OF columna1, columna2 ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION funcion();
```

### DELETE
```sql
CREATE TRIGGER trigger_nombre
  BEFORE DELETE ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION funcion();
```

### Múltiples eventos
```sql
CREATE TRIGGER trigger_nombre
  BEFORE INSERT OR UPDATE OR DELETE ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION funcion();
```

## Gestión de Triggers

### Crear Trigger
```sql
CREATE TRIGGER nombre_trigger ...
```

### Eliminar Trigger
```sql
DROP TRIGGER IF EXISTS nombre_trigger ON nombre_tabla;
```

### Deshabilitar Trigger
```sql
ALTER TABLE nombre_tabla DISABLE TRIGGER nombre_trigger;

-- Deshabilitar todos los triggers de una tabla
ALTER TABLE nombre_tabla DISABLE TRIGGER ALL;
```

### Habilitar Trigger
```sql
ALTER TABLE nombre_tabla ENABLE TRIGGER nombre_trigger;

-- Habilitar todos los triggers
ALTER TABLE nombre_tabla ENABLE TRIGGER ALL;
```

### Listar Triggers
```sql
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'nombre_tabla';
```

### Ver Definición
```sql
SELECT pg_get_triggerdef(oid)
FROM pg_trigger
WHERE tgname = 'nombre_trigger';
```

## Orden de Ejecución

Cuando hay múltiples triggers en la misma tabla:
1. BEFORE triggers se ejecutan primero (en orden alfabético)
2. La operación (INSERT/UPDATE/DELETE) ocurre
3. AFTER triggers se ejecutan (en orden alfabético)

**Controlar el orden:**
```sql
-- Triggers se ejecutan en orden alfabético, puedes usar prefijos:
CREATE TRIGGER 01_primer_trigger ...
CREATE TRIGGER 02_segundo_trigger ...
```

## Variables Especiales en Funciones de Trigger

Dentro de una función de trigger, tienes acceso a:

- **NEW**: Registro nuevo (INSERT/UPDATE)
- **OLD**: Registro anterior (UPDATE/DELETE)
- **TG_OP**: Tipo de operación ('INSERT', 'UPDATE', 'DELETE')
- **TG_TABLE_NAME**: Nombre de la tabla
- **TG_WHEN**: 'BEFORE' o 'AFTER'

```sql
CREATE OR REPLACE FUNCTION mi_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- Usar NEW para datos nuevos
    NEW.created_at = NOW();
  ELSIF TG_OP = 'UPDATE' THEN
    -- Comparar OLD y NEW
    IF OLD.status != NEW.status THEN
      -- Hacer algo cuando cambia el status
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    -- Usar OLD para datos que se están eliminando
    INSERT INTO audit_log VALUES (OLD.id, 'deleted');
  END IF;

  RETURN NEW; -- o OLD para DELETE
END;
$$ LANGUAGE plpgsql;
```

## Mejores Prácticas

1. **Nombres Descriptivos**: Usa formato `accion_tabla_evento`
   - ✅ `update_subscribers_updated_at`
   - ✅ `validate_email_before_insert`
   - ❌ `trigger1`

2. **Documentación**: Explica qué hace y por qué existe

3. **Performance**:
   - Los triggers agregan overhead
   - Evita lógica compleja en triggers de alta frecuencia
   - Considera mover lógica pesada a jobs asíncronos

4. **Testing**: Prueba todos los casos (INSERT, UPDATE, DELETE)

5. **Separación**: Un trigger = un propósito

6. **Funciones Reutilizables**: Usa funciones que puedan ser compartidas

## Ejemplos Comunes

### Actualizar Timestamp
```sql
-- triggers/update_tabla_updated_at.sql
CREATE TRIGGER update_tabla_updated_at
  BEFORE UPDATE ON tabla
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Validación Antes de Insertar
```sql
-- triggers/validate_subscriber_before_insert.sql
CREATE TRIGGER validate_subscriber_before_insert
  BEFORE INSERT ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION validate_subscriber_data();

-- Función correspondiente:
CREATE OR REPLACE FUNCTION validate_subscriber_data()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email IS NULL OR NEW.email = '' THEN
    RAISE EXCEPTION 'Email no puede estar vacío';
  END IF;

  IF NOT NEW.terms_accepted THEN
    RAISE EXCEPTION 'Debe aceptar términos y condiciones';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Auditoría de Cambios
```sql
-- triggers/audit_subscriber_changes.sql
CREATE TRIGGER audit_subscriber_changes
  AFTER UPDATE OR DELETE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION log_subscriber_audit();

-- Función correspondiente:
CREATE OR REPLACE FUNCTION log_subscriber_audit()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_data, new_data)
    VALUES ('subscribers', OLD.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW));
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_data)
    VALUES ('subscribers', OLD.id, 'DELETE', row_to_json(OLD));
  END IF;

  RETURN NULL; -- El valor de retorno se ignora en AFTER triggers
END;
$$ LANGUAGE plpgsql;
```

### Prevenir Eliminación
```sql
-- triggers/prevent_subscriber_delete.sql
CREATE TRIGGER prevent_subscriber_delete
  BEFORE DELETE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION prevent_hard_delete();

CREATE OR REPLACE FUNCTION prevent_hard_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- En lugar de eliminar, marcamos como eliminado
  UPDATE subscribers
  SET status = 'deleted', updated_at = NOW()
  WHERE id = OLD.id;

  -- Prevenir la eliminación real
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

### Sincronización Entre Tablas
```sql
-- triggers/sync_subscriber_count.sql
CREATE TRIGGER sync_subscriber_count
  AFTER INSERT OR DELETE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION update_campaign_subscriber_count();

CREATE OR REPLACE FUNCTION update_campaign_subscriber_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE campaigns
    SET subscriber_count = subscriber_count + 1
    WHERE name = NEW.utm_campaign;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE campaigns
    SET subscriber_count = subscriber_count - 1
    WHERE name = OLD.utm_campaign;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

## Consideraciones de Performance

### ⚠️ Cuidado con:
- Triggers que llaman a funciones pesadas
- Triggers que hacen múltiples queries
- Triggers en tablas de alta escritura
- Triggers recursivos

### ✅ Optimizaciones:
- Usa `FOR EACH STATEMENT` en lugar de `FOR EACH ROW` cuando sea posible
- Filtra con `WHEN` clause para evitar ejecuciones innecesarias
- Considera jobs asíncronos para operaciones pesadas

```sql
-- Ejecutar solo cuando cambia el status
CREATE TRIGGER notify_status_change
  AFTER UPDATE OF status ON subscribers
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION notify_status_change();
```

---

Para más información, consulta el [README principal](../README.md).