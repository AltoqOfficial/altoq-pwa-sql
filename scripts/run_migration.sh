#!/bin/bash

# ============================================================================
# Script para ejecutar migraciones de base de datos
# Uso: ./run_migration.sh <numero_migracion>
# Ejemplo: ./run_migration.sh 001
# ============================================================================

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que se proporcionó un número de migración
if [ -z "$1" ]; then
  echo -e "${RED}Error: Debes proporcionar el número de migración${NC}"
  echo "Uso: ./run_migration.sh <numero_migracion>"
  echo "Ejemplo: ./run_migration.sh 001"
  exit 1
fi

MIGRATION_NUM=$1
MIGRATION_FILE="migrations/${MIGRATION_NUM}_*.sql"

# Buscar el archivo de migración
MIGRATION_PATH=$(ls $MIGRATION_FILE 2>/dev/null | head -n 1)

if [ -z "$MIGRATION_PATH" ]; then
  echo -e "${RED}Error: No se encontró migración ${MIGRATION_NUM}${NC}"
  echo "Archivos disponibles:"
  ls migrations/*.sql 2>/dev/null || echo "  (ninguno)"
  exit 1
fi

echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}Ejecutando migración: $MIGRATION_PATH${NC}"
echo -e "${YELLOW}=====================================${NC}"

# Verificar variables de entorno
if [ -z "$SUPABASE_DB_URL" ] && [ -z "$DATABASE_URL" ]; then
  echo -e "${RED}Error: Debes configurar SUPABASE_DB_URL o DATABASE_URL${NC}"
  echo ""
  echo "Opción 1 - Variables de entorno:"
  echo "  export SUPABASE_DB_URL='postgresql://postgres:[password]@db.[project].supabase.co:5432/postgres'"
  echo ""
  echo "Opción 2 - Usar .env file:"
  echo "  Crea un archivo .env con DATABASE_URL=..."
  exit 1
fi

# Usar SUPABASE_DB_URL si está disponible, sino DATABASE_URL
DB_URL=${SUPABASE_DB_URL:-$DATABASE_URL}

# Confirmar antes de ejecutar
echo ""
echo -e "${YELLOW}Base de datos: ${DB_URL%%@*}@***${NC}"
echo ""
read -p "¿Estás seguro de ejecutar esta migración? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo -e "${YELLOW}Migración cancelada${NC}"
  exit 0
fi

# Ejecutar migración
echo ""
echo -e "${GREEN}Ejecutando migración...${NC}"
psql "$DB_URL" -f "$MIGRATION_PATH"

if [ $? -eq 0 ]; then
  echo ""
  echo -e "${GREEN}=====================================${NC}"
  echo -e "${GREEN}✓ Migración ejecutada exitosamente${NC}"
  echo -e "${GREEN}=====================================${NC}"
  echo ""
  echo -e "${YELLOW}No olvides:${NC}"
  echo "  1. Actualizar CHANGELOG.md"
  echo "  2. Crear el rollback si no existe"
  echo "  3. Hacer commit de los cambios"
else
  echo ""
  echo -e "${RED}=====================================${NC}"
  echo -e "${RED}✗ Error al ejecutar la migración${NC}"
  echo -e "${RED}=====================================${NC}"
  exit 1
fi