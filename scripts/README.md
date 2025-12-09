# Scripts de Utilidad

Scripts auxiliares para facilitar el trabajo con la base de datos.

## Contenido

### run_migration.sh / run_migration.bat

Scripts para ejecutar migraciones de forma segura.

#### Linux/Mac (Bash)

```bash
# Dar permisos de ejecución (solo primera vez)
chmod +x scripts/run_migration.sh

# Ejecutar migración
./scripts/run_migration.sh 001
```

#### Windows (Batch)

```cmd
scripts\run_migration.bat 001
```

#### Configuración

Antes de usar los scripts, configura tu conexión a la base de datos:

**Opción 1: Variable de entorno**
```bash
# Linux/Mac
export SUPABASE_DB_URL="postgresql://postgres:[password]@db.[project].supabase.co:5432/postgres"

# Windows
set SUPABASE_DB_URL=postgresql://postgres:[password]@db.[project].supabase.co:5432/postgres
```

**Opción 2: Archivo .env (recomendado)**
```bash
# Crear archivo .env en la raíz del proyecto
DATABASE_URL=postgresql://postgres:[password]@db.[project].supabase.co:5432/postgres
```

#### Requisitos

- **PostgreSQL client (psql)** instalado
  - Mac: `brew install postgresql`
  - Windows: Descarga desde [postgresql.org](https://www.postgresql.org/download/)
  - Linux: `sudo apt-get install postgresql-client`

## Crear Nuevos Scripts

Si necesitas agregar scripts de utilidad adicionales:

1. Crea el archivo en esta carpeta (`/scripts/`)
2. Dale un nombre descriptivo
3. Incluye comentarios de uso
4. Para scripts bash, hazlos ejecutables: `chmod +x script.sh`
5. Documéntalos en este README

## Ejemplos de Scripts Útiles

### Backup de Base de Datos

```bash
#!/bin/bash
# backup.sh - Crear backup de la base de datos

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
pg_dump "$DATABASE_URL" > "backups/backup_$TIMESTAMP.sql"
echo "Backup creado: backups/backup_$TIMESTAMP.sql"
```

### Listar Migraciones Pendientes

```bash
#!/bin/bash
# list_pending.sh - Mostrar migraciones disponibles

echo "Migraciones disponibles:"
ls -1 migrations/*.sql
```

### Ejecutar Rollback

```bash
#!/bin/bash
# rollback.sh - Ejecutar un rollback específico

if [ -z "$1" ]; then
  echo "Uso: ./rollback.sh <numero>"
  exit 1
fi

psql "$DATABASE_URL" -f "rollbacks/rollback_$1.sql"
```

---

Para más información, consulta el [README principal](../README.md).