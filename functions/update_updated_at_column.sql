-- ============================================================================
-- Function: update_updated_at_column
-- Description: Función reutilizable para actualizar automáticamente el campo
--              updated_at cada vez que se modifica un registro
-- Author: Tadeo Portillo
-- Date: 2025-12-08
-- ============================================================================

-- ============================================================================
-- Usage:
-- ============================================================================
-- Esta función se usa típicamente con un trigger:
--
-- CREATE TRIGGER update_[tabla]_updated_at
--   BEFORE UPDATE ON [tabla]
--   FOR EACH ROW
--   EXECUTE FUNCTION update_updated_at_column();
--
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualiza el campo updated_at con el timestamp actual
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Comentarios para documentación
-- ============================================================================

COMMENT ON FUNCTION update_updated_at_column() IS
  'Función trigger que actualiza automáticamente el campo updated_at con el timestamp actual. Debe ser usada con un trigger BEFORE UPDATE.';