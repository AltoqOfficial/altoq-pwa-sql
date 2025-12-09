-- ============================================================================
-- Rollback: [NÚMERO]_[DESCRIPCIÓN]
-- Description: Revierte la migración [NÚMERO]_[DESCRIPCIÓN]
-- Author: [Tu nombre]
-- Date: [YYYY-MM-DD]
-- ============================================================================

-- ============================================================================
-- ADVERTENCIA: ROLLBACK SCRIPT
-- ============================================================================
-- Este script REVERTIRÁ los cambios de la migración [NÚMERO]
-- Úsalo SOLO si necesitas deshacer la migración
--
-- Antes de ejecutar:
-- [ ] Haz backup de la base de datos
-- [ ] Verifica que entiendes qué se va a revertir
-- [ ] Confirma que tienes permiso para ejecutar este rollback
-- [ ] Considera el impacto en datos existentes

-- ============================================================================
-- Qué se va a revertir
-- ============================================================================
-- 1. [Describe qué se revertirá 1]
-- 2. [Describe qué se revertirá 2]
-- 3. [Describe qué se revertirá 3]

-- ============================================================================
-- BEGIN ROLLBACK
-- ============================================================================

-- Ejemplo: Eliminar trigger
-- DROP TRIGGER IF EXISTS nombre_trigger ON nombre_tabla;

-- Ejemplo: Eliminar función
-- DROP FUNCTION IF EXISTS nombre_funcion();

-- Ejemplo: Eliminar índice
-- DROP INDEX IF EXISTS idx_tabla_columna;

-- Ejemplo: Eliminar columna
-- ALTER TABLE tabla_existente
-- DROP COLUMN IF EXISTS nueva_columna;

-- Ejemplo: Eliminar tabla
-- DROP TABLE IF EXISTS nombre_tabla;

-- Ejemplo: Eliminar política RLS
-- DROP POLICY IF EXISTS "nombre_policy" ON nombre_tabla;

-- ============================================================================
-- Restauración de datos (si es necesario)
-- ============================================================================

-- UPDATE tabla SET columna = valor_anterior WHERE condicion;

-- ============================================================================
-- END ROLLBACK
-- ============================================================================

-- ============================================================================
-- Verificación post-rollback
-- ============================================================================

-- Verifica que los cambios se revirtieron correctamente
-- SELECT * FROM pg_tables WHERE tablename = 'nombre_tabla';

-- ============================================================================
-- Notas
-- ============================================================================
--
-- [Documenta cualquier efecto secundario del rollback]
-- [Menciona si hay pérdida de datos]
-- [Indica pasos manuales adicionales si son necesarios]
--