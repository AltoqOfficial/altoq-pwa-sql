# AltoQ PWA - Base de Datos SQL

Repositorio para el versionado y gestión de scripts SQL del proyecto **altoq-pwa**.

## Descripción

Este repositorio mantiene todos los scripts de base de datos, migraciones, funciones y políticas de seguridad utilizados en el proyecto AltoQ PWA con Supabase (PostgreSQL).

## Estructura del Proyecto

```
altoq-pwa-sql/
├── migrations/          # Scripts de migración de la base de datos (ordenados)
├── seeds/              # Datos iniciales y de prueba
├── functions/          # Funciones de PostgreSQL/PL-pgSQL
├── views/              # Vistas de la base de datos
├── policies/           # Políticas de Row Level Security (RLS)
├── triggers/           # Triggers de la base de datos
├── rollbacks/          # Scripts para revertir migraciones
├── docs/               # Documentación adicional
└── scripts/            # Scripts de utilidad y automatización
```

## Migraciones

Las migraciones siguen un sistema de numeración secuencial:

- `001_initial_subscribers_table.sql` - Configuración inicial de tabla subscribers
- `002_nombre_descriptivo.sql` - Próximas migraciones...
- `003_nombre_descriptivo.sql` - ...

### Cómo Crear una Nueva Migración

1. Crea un nuevo archivo en `/migrations/` con el siguiente número secuencial
2. Usa un nombre descriptivo: `XXX_descripcion_del_cambio.sql`
3. Incluye comentarios explicando el propósito del cambio
4. Si es posible, crea el script de rollback correspondiente en `/rollbacks/`

### Ejecutar Migraciones

#### Opción 1: Supabase Dashboard (Recomendado para desarrollo)
1. Accede a tu proyecto en [Supabase](https://app.supabase.com)
2. Ve a **SQL Editor**
3. Copia y pega el contenido de la migración
4. Ejecuta el script

#### Opción 2: Supabase CLI
```bash
# Iniciar sesión en Supabase
supabase login

# Ejecutar migración
supabase db push

# O ejecutar un archivo específico
psql -h <HOST> -U postgres -d postgres -f migrations/001_initial_subscribers_table.sql
```

#### Opción 3: Cliente PostgreSQL (psql)
```bash
psql -h db.your-project.supabase.co -U postgres -d postgres -f migrations/XXX_migration.sql
```

## Conexión a la Base de Datos

### Variables de Entorno Requeridas

Asegúrate de tener configuradas las siguientes variables en tu archivo `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

**IMPORTANTE:** Nunca versiones archivos `.env` con credenciales reales.

## Esquema Actual

### Tabla: `subscribers`

Almacena información de suscriptores con metadata completa para análisis.

**Campos principales:**
- `id` - UUID único
- `email` - Email del suscriptor (único)
- `status` - Estado: active | unsubscribed
- `created_at` / `updated_at` - Timestamps automáticos
- Metadata del dispositivo, localización y origen

Para ver el esquema completo, consulta [migrations/001_initial_subscribers_table.sql](migrations/001_initial_subscribers_table.sql)

## Git Flow

Este proyecto utiliza **Git Flow** para gestión de versiones:

- **`main`** - Código en producción (solo releases)
- **`develop`** - Desarrollo activo (rama principal de trabajo)
- **`feature/*`** - Nuevas funcionalidades
- **`hotfix/*`** - Correcciones urgentes
- **`release/*`** - Preparación de versiones

**Flujo de trabajo:**

```bash
# Crear nueva feature
git checkout develop
git checkout -b feature/nombre-feature

# Hacer commits...
git commit -m "Descripción del cambio"

# Integrar a develop
git checkout develop
git merge feature/nombre-feature --no-ff
```

Para más detalles, consulta [docs/GIT_WORKFLOW.md](docs/GIT_WORKFLOW.md)

## Convenciones

### Nomenclatura

- **Tablas:** snake_case, plural (ej: `subscribers`, `user_profiles`)
- **Columnas:** snake_case (ej: `created_at`, `user_id`)
- **Índices:** `idx_tabla_columna` (ej: `idx_subscribers_email`)
- **Funciones:** snake_case, verbo descriptivo (ej: `update_updated_at_column`)
- **Triggers:** `accion_tabla_evento` (ej: `update_subscribers_updated_at`)

### Comentarios en SQL

Siempre incluye:
- Comentarios de tabla con `COMMENT ON TABLE`
- Comentarios de columnas con `COMMENT ON COLUMN`
- Comentarios inline para lógica compleja

### Índices

Crea índices para:
- Columnas usadas en WHERE, JOIN, ORDER BY frecuentemente
- Columnas UNIQUE
- Foreign keys

### Row Level Security (RLS)

- Documenta por qué RLS está habilitado o deshabilitado
- Si está habilitado, define políticas claras
- Guarda políticas en `/policies/`

## Rollbacks

Si necesitas revertir una migración:

1. Busca el archivo correspondiente en `/rollbacks/`
2. Revisa cuidadosamente antes de ejecutar
3. Ejecuta el script de rollback
4. Documenta el rollback en `CHANGELOG.md`

## Mantenimiento

### Antes de Hacer Cambios

1. **Backup:** Siempre haz backup de la base de datos de producción
2. **Testing:** Prueba las migraciones en desarrollo/staging primero
3. **Revisión:** Revisa el código SQL antes de aplicarlo
4. **Documentación:** Actualiza este README y CHANGELOG.md

### Buenas Prácticas

- ✅ Usa transacciones cuando sea posible
- ✅ Incluye validaciones y constraints
- ✅ Documenta todos los cambios
- ✅ Prueba rollbacks antes de aplicar a producción
- ✅ Mantén las migraciones pequeñas y enfocadas
- ❌ No modifiques migraciones ya aplicadas
- ❌ No versiones datos sensibles o de producción
- ❌ No hagas cambios destructivos sin backup

## Recursos

- [Documentación de Supabase](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

## Soporte

Para preguntas o problemas relacionados con la base de datos, contacta al equipo de desarrollo de altoq-pwa.

---

**Última actualización:** 2025-12-08
**Versión de PostgreSQL:** 15.x (Supabase)