# Git Flow Workflow

Este proyecto utiliza **Git Flow** para gestionar el desarrollo de forma organizada y profesional.

## Estructura de Ramas

### Ramas Principales (Permanentes)

#### `main`
- **Propósito:** Código en producción
- **Estabilidad:** 100% estable
- **Despliegues:** Solo desde esta rama
- **Protección:** No hacer commits directos, solo merges desde `develop`

#### `develop`
- **Propósito:** Rama de desarrollo activo
- **Estabilidad:** Relativamente estable
- **Integración:** Todas las features se integran aquí
- **Base:** Para crear nuevas ramas de feature/hotfix

### Ramas Temporales

#### `feature/*`
Para desarrollar nuevas funcionalidades
- Ejemplo: `feature/add-user-profiles-table`
- Ejemplo: `feature/analytics-views`

#### `hotfix/*`
Para correcciones urgentes en producción
- Ejemplo: `hotfix/fix-email-validation`
- Ejemplo: `hotfix/fix-rls-policy`

#### `release/*`
Para preparar una nueva versión
- Ejemplo: `release/v1.1.0`

## Flujo de Trabajo

### 1. Desarrollar una Nueva Feature

```bash
# 1. Asegúrate de estar en develop actualizado
git checkout develop
git pull origin develop

# 2. Crear rama de feature
git checkout -b feature/nombre-descriptivo

# Ejemplo:
git checkout -b feature/add-analytics-views

# 3. Desarrollar y hacer commits
# Editar archivos...
git add .
git commit -m "Add subscriber analytics views

- Create view for subscribers_by_country
- Create materialized view for campaign_stats
- Add indexes for performance

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 4. Cuando termines, integrar a develop
git checkout develop
git merge feature/add-analytics-views --no-ff

# 5. Eliminar rama de feature
git branch -d feature/add-analytics-views

# 6. Push a remoto
git push origin develop
```

### 2. Crear una Migración Nueva

```bash
# 1. Crear feature branch
git checkout develop
git checkout -b feature/migration-002-user-profiles

# 2. Crear los archivos necesarios
# - migrations/002_add_user_profiles.sql
# - rollbacks/rollback_002.sql
# - (funciones/triggers si es necesario)

# 3. Actualizar CHANGELOG.md

# 4. Commit
git add .
git commit -m "Add migration 002: user_profiles table

- Create user_profiles table with authentication fields
- Add foreign key to subscribers table
- Create indexes for performance
- Add rollback script
- Update CHANGELOG.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 5. Merge a develop
git checkout develop
git merge feature/migration-002-user-profiles --no-ff
git branch -d feature/migration-002-user-profiles
```

### 3. Preparar Release para Producción

```bash
# 1. Crear rama de release desde develop
git checkout develop
git checkout -b release/v1.1.0

# 2. Hacer ajustes finales (versión, CHANGELOG, etc.)
# Editar CHANGELOG.md con versión final
git add CHANGELOG.md
git commit -m "Prepare release v1.1.0"

# 3. Merge a main (producción)
git checkout main
git merge release/v1.1.0 --no-ff
git tag -a v1.1.0 -m "Release version 1.1.0"

# 4. Merge de vuelta a develop
git checkout develop
git merge release/v1.1.0 --no-ff

# 5. Eliminar rama de release
git branch -d release/v1.1.0

# 6. Push todo
git push origin main
git push origin develop
git push origin --tags
```

### 4. Hotfix Urgente en Producción

```bash
# 1. Crear hotfix desde main
git checkout main
git checkout -b hotfix/fix-email-constraint

# 2. Hacer el fix
# Editar archivos...
git add .
git commit -m "Fix email validation constraint

Critical fix for email validation in subscribers table

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 3. Merge a main
git checkout main
git merge hotfix/fix-email-constraint --no-ff
git tag -a v1.0.1 -m "Hotfix v1.0.1 - Fix email validation"

# 4. Merge a develop también
git checkout develop
git merge hotfix/fix-email-constraint --no-ff

# 5. Eliminar rama hotfix
git branch -d hotfix/fix-email-constraint

# 6. Push
git push origin main
git push origin develop
git push origin --tags
```

## Convenciones de Nombres

### Ramas

```
feature/nombre-descriptivo-en-kebab-case
hotfix/descripcion-del-problema
release/vX.Y.Z
```

### Commits

Formato:
```
Título corto (50 caracteres max)

- Detalle 1
- Detalle 2
- Detalle 3

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

Ejemplos:
- `Add migration 003: add orders table`
- `Fix RLS policy for subscribers table`
- `Update documentation for triggers`
- `Create view for monthly analytics`

### Tags (Versiones)

Seguir [Semantic Versioning](https://semver.org/):
- `v1.0.0` - Primera versión estable
- `v1.1.0` - Nueva funcionalidad (minor)
- `v1.0.1` - Corrección de bugs (patch)
- `v2.0.0` - Cambios incompatibles (major)

## Comandos Útiles

### Ver el estado actual
```bash
git status
git branch -a
git log --oneline --graph --all --decorate
```

### Ver diferencias
```bash
# Entre ramas
git diff develop..main

# En archivos específicos
git diff migrations/001_initial_subscribers_table.sql
```

### Ver historial
```bash
# Log compacto
git log --oneline -10

# Log con gráfico
git log --graph --oneline --all

# Ver cambios de un archivo
git log --follow migrations/001_initial_subscribers_table.sql
```

### Deshacer cambios (con cuidado)
```bash
# Descartar cambios no staged
git checkout -- archivo.sql

# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Deshacer último commit (eliminar cambios)
git reset --hard HEAD~1  # ⚠️ PELIGROSO
```

## Protección de Ramas (Recomendado)

Si usas GitHub/GitLab, configura:

### Para `main`:
- ✅ Require pull request reviews
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Include administrators
- ❌ Allow force pushes

### Para `develop`:
- ✅ Require pull request reviews (opcional)
- ✅ Require branches to be up to date
- ❌ Allow force pushes

## Ejemplo Completo: Nueva Funcionalidad

```bash
# Día 1: Empezar feature
git checkout develop
git pull origin develop
git checkout -b feature/add-utm-analytics

# Trabajar en la feature...
# Crear: views/utm_analytics.sql

git add views/utm_analytics.sql
git commit -m "Add UTM campaign analytics view

- Create utm_analytics view with conversion metrics
- Include device type breakdown
- Add geographic distribution

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Día 2: Continuar desarrollo
# Crear: seeds/sample_utm_data.sql

git add seeds/sample_utm_data.sql
git commit -m "Add sample UTM data for testing

- Include diverse campaign examples
- Cover multiple traffic sources
- Test data for analytics view

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Día 3: Finalizar e integrar
git checkout develop
git pull origin develop  # Asegurar que develop está actualizado
git merge feature/add-utm-analytics --no-ff
git branch -d feature/add-utm-analytics
git push origin develop
```

## Mejores Prácticas

1. **Commits Frecuentes**: Haz commits pequeños y atómicos
2. **Mensajes Descriptivos**: Explica QUÉ y POR QUÉ, no CÓMO
3. **Pull Antes de Push**: Siempre haz `git pull` antes de `git push`
4. **Revisar Cambios**: Usa `git diff` antes de commitear
5. **Rama Actualizada**: Mantén tu rama actualizada con develop
6. **No Reescribir Historia Pública**: No uses `rebase` o `force push` en ramas compartidas
7. **Eliminar Ramas**: Borra ramas feature/hotfix después de merge

## Resolución de Conflictos

```bash
# 1. Intentar merge
git checkout develop
git merge feature/mi-feature

# Si hay conflictos...
# 2. Ver archivos en conflicto
git status

# 3. Editar archivos manualmente, buscar:
# <<<<<<< HEAD
# código en develop
# =======
# código en feature
# >>>>>>> feature/mi-feature

# 4. Después de resolver
git add archivo-resuelto.sql
git commit -m "Merge feature/mi-feature into develop

Resolved conflicts in:
- migrations/002_tabla.sql

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Diagrama de Git Flow

```
main        o------------------o----------------------o
            |                  ^                      ^
            |                  | (release merge)      | (hotfix)
            |                  |                      |
develop     o----o----o----o---o----o----o-----------o
            |    ^    ^    ^        ^    ^
            |    |    |    |        |    |
feature/A        o----o    |        |    |
                           |        |    |
feature/B                  o--------o    |
                                         |
feature/C                                o
```

## Estado Actual del Proyecto

```bash
# Ver en qué rama estás
$ git branch
* develop
  main

# Ver último commit
$ git log --oneline -1
3527912 Initial repository structure for SQL version control
```

**Rama actual:** `develop`
**Siguiente paso:** Crear features para nuevas funcionalidades

---

Para más información sobre Git Flow:
- [Git Flow Cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [A successful Git branching model](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)
