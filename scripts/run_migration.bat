@echo off
REM ============================================================================
REM Script para ejecutar migraciones de base de datos (Windows)
REM Uso: run_migration.bat <numero_migracion>
REM Ejemplo: run_migration.bat 001
REM ============================================================================

setlocal enabledelayedexpansion

REM Verificar que se proporcionó un número de migración
if "%1"=="" (
  echo Error: Debes proporcionar el numero de migracion
  echo Uso: run_migration.bat ^<numero_migracion^>
  echo Ejemplo: run_migration.bat 001
  exit /b 1
)

set MIGRATION_NUM=%1

REM Buscar el archivo de migración
set MIGRATION_FILE=
for %%f in (migrations\%MIGRATION_NUM%_*.sql) do (
  set MIGRATION_FILE=%%f
  goto :found
)

echo Error: No se encontro migracion %MIGRATION_NUM%
echo Archivos disponibles:
dir /b migrations\*.sql 2>nul
exit /b 1

:found
echo =====================================
echo Ejecutando migracion: %MIGRATION_FILE%
echo =====================================

REM Verificar variables de entorno
if "%SUPABASE_DB_URL%"=="" if "%DATABASE_URL%"=="" (
  echo Error: Debes configurar SUPABASE_DB_URL o DATABASE_URL
  echo.
  echo Ejemplo:
  echo   set SUPABASE_DB_URL=postgresql://postgres:[password]@db.[project].supabase.co:5432/postgres
  echo.
  exit /b 1
)

REM Usar SUPABASE_DB_URL si está disponible, sino DATABASE_URL
if not "%SUPABASE_DB_URL%"=="" (
  set DB_URL=%SUPABASE_DB_URL%
) else (
  set DB_URL=%DATABASE_URL%
)

echo.
set /p CONFIRM="Estas seguro de ejecutar esta migracion? (yes/no): "

if /i not "%CONFIRM%"=="yes" (
  echo Migracion cancelada
  exit /b 0
)

echo.
echo Ejecutando migracion...
psql "%DB_URL%" -f "%MIGRATION_FILE%"

if %errorlevel% equ 0 (
  echo.
  echo =====================================
  echo Migracion ejecutada exitosamente
  echo =====================================
  echo.
  echo No olvides:
  echo   1. Actualizar CHANGELOG.md
  echo   2. Crear el rollback si no existe
  echo   3. Hacer commit de los cambios
) else (
  echo.
  echo =====================================
  echo Error al ejecutar la migracion
  echo =====================================
  exit /b 1
)

endlocal