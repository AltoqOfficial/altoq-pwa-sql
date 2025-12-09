-- ============================================================================
-- Trigger: update_subscribers_updated_at
-- Description: Trigger que actualiza automáticamente el campo updated_at
--              de la tabla subscribers antes de cada UPDATE
-- Table: subscribers
-- Author: Tadeo Portillo
-- Date: 2025-12-08
-- ============================================================================

-- ============================================================================
-- Dependencies:
-- ============================================================================
-- Requiere: functions/update_updated_at_column.sql
-- Requiere: tabla subscribers existente con columna updated_at
--
-- ============================================================================

CREATE TRIGGER update_subscribers_updated_at
  BEFORE UPDATE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Verificación
-- ============================================================================
-- Para verificar que el trigger funciona:
--
-- UPDATE subscribers SET email = email WHERE id = [algún_id];
-- SELECT id, email, updated_at FROM subscribers WHERE id = [algún_id];
--
-- El campo updated_at debería haberse actualizado automáticamente
-- ============================================================================