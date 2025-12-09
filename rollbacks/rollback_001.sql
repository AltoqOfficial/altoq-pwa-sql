-- ============================================================================
-- Rollback: 001_initial_subscribers_table
-- Description: Revierte la migración 001_initial_subscribers_table
--              Elimina la tabla subscribers y todos sus objetos relacionados
-- Author: Tadeo Portillo
-- Date: 2025-12-08
-- ============================================================================

-- ============================================================================
-- ADVERTENCIA: ROLLBACK SCRIPT
-- ============================================================================
-- Este script REVERTIRÁ los cambios de la migración 001
-- Úsalo SOLO si necesitas deshacer la migración
--
-- Antes de ejecutar:
-- [ ] Haz backup de la base de datos
-- [ ] Verifica que entiendes qué se va a revertir
-- [ ] Confirma que tienes permiso para ejecutar este rollback
-- [ ] Considera el impacto en datos existentes
-- [ ] ADVERTENCIA: Se perderán TODOS los datos de la tabla subscribers

-- ============================================================================
-- Qué se va a revertir
-- ============================================================================
-- 1. Trigger: update_subscribers_updated_at
-- 2. Función: update_updated_at_column (solo si no la usa ninguna otra tabla)
-- 3. Tabla: subscribers (con TODOS sus datos)
-- 4. Todos los índices asociados (se eliminan automáticamente con la tabla)
-- 5. Todos los comentarios (se eliminan automáticamente con la tabla)

-- ============================================================================
-- BEGIN ROLLBACK
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Eliminar trigger
-- ----------------------------------------------------------------------------

DROP TRIGGER IF EXISTS update_subscribers_updated_at ON subscribers;

-- ----------------------------------------------------------------------------
-- 2. Eliminar tabla (esto también elimina índices y comentarios)
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS subscribers CASCADE;

-- ----------------------------------------------------------------------------
-- 3. Eliminar función (OPCIONAL - solo si no la usa ninguna otra tabla)
-- ----------------------------------------------------------------------------
-- IMPORTANTE: Descomenta las siguientes líneas SOLO si estás seguro de que
-- ninguna otra tabla usa esta función. Si tienes dudas, déjala comentada.

-- DROP FUNCTION IF EXISTS update_updated_at_column();

-- ============================================================================
-- END ROLLBACK
-- ============================================================================

-- ============================================================================
-- Verificación post-rollback
-- ============================================================================

-- Verificar que la tabla ya no existe
SELECT tablename FROM pg_tables WHERE tablename = 'subscribers';
-- Resultado esperado: 0 filas

-- Verificar que el trigger ya no existe
SELECT trigger_name FROM information_schema.triggers
WHERE event_object_table = 'subscribers';
-- Resultado esperado: 0 filas

-- Verificar si la función todavía existe (en caso de que no la hayas eliminado)
SELECT proname FROM pg_proc WHERE proname = 'update_updated_at_column';
-- Si devuelve 1 fila, la función aún existe (puede estar siendo usada por otras tablas)
-- Si devuelve 0 filas, la función fue eliminada completamente

-- ============================================================================
-- Notas
-- ============================================================================
--
-- PÉRDIDA DE DATOS:
-- - TODOS los datos de suscriptores se perderán permanentemente
-- - NO hay forma de recuperarlos sin un backup previo
-- - Los emails, metadata y estadísticas se eliminarán completamente
--
-- DEPENDENCIAS:
-- - Si hay otras tablas con foreign keys a subscribers, usa CASCADE
-- - Si hay vistas que referencian subscribers, también se eliminarán
--
-- FUNCIÓN update_updated_at_column:
-- - Esta función puede ser usada por MÚLTIPLES tablas
-- - NO la elimines si otras tablas dependen de ella
-- - Para verificar dependencias:
--   SELECT DISTINCT trigger_name, event_object_table
--   FROM information_schema.triggers
--   WHERE action_statement LIKE '%update_updated_at_column%';
--
-- PASOS MANUALES ADICIONALES:
-- - Actualizar CHANGELOG.md documentando el rollback
-- - Notificar al equipo sobre la reversión
-- - Revisar logs de aplicación para asegurar que no hay errores
-- - Si hay datos críticos, considera restaurar desde backup selectivamente
--
-- RECOMENDACIÓN:
-- En lugar de hacer rollback completo, considera:
-- - Renombrar la tabla: ALTER TABLE subscribers RENAME TO subscribers_old;
-- - Esto preserva los datos mientras pruebas la nueva estructura
--
-- ============================================================================