# Documentación

Esta carpeta contiene documentación adicional y plantillas para el proyecto.

## Contenido

### Plantillas

- **[migration_template.sql](migration_template.sql)** - Plantilla para crear nuevas migraciones
- **[rollback_template.sql](rollback_template.sql)** - Plantilla para crear scripts de rollback

### Uso de las Plantillas

#### Crear una Nueva Migración

1. Copia el archivo `migration_template.sql`
2. Renómbralo siguiendo la convención: `XXX_descripcion.sql` (donde XXX es el siguiente número)
3. Muévelo a la carpeta `/migrations/`
4. Llena los campos necesarios:
   - Número de migración
   - Descripción
   - Autor
   - Fecha
   - Cambios principales
5. Escribe tu código SQL
6. Crea el rollback correspondiente

#### Crear un Rollback

1. Copia el archivo `rollback_template.sql`
2. Renómbralo con el mismo número de la migración: `rollback_XXX.sql`
3. Muévelo a la carpeta `/rollbacks/`
4. Escribe el código que revierte la migración correspondiente

## Buenas Prácticas

### Migraciones

- Una migración = un propósito específico
- Incluye comentarios explicativos
- Usa `IF NOT EXISTS` cuando sea apropiado
- Documenta el impacto en datos existentes
- Siempre crea el rollback correspondiente

### Documentación

- Actualiza `CHANGELOG.md` con cada cambio
- Documenta decisiones de diseño importantes
- Incluye ejemplos de uso cuando sea relevante
- Mantén diagramas actualizados si los usas

## Convenciones de SQL

### Formato

```sql
-- Buenos comentarios explican el POR QUÉ, no el QUÉ
CREATE TABLE IF NOT EXISTS usuarios (
  -- Clave primaria auto-generada
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Email único para login
  email TEXT UNIQUE NOT NULL,

  -- Timestamps estándar
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices después de la definición de tabla
CREATE INDEX IF NOT EXISTS idx_usuarios_email
ON usuarios(email);
```

### Nomenclatura

- **Tablas:** `snake_case`, plural
- **Columnas:** `snake_case`
- **Índices:** `idx_tabla_columna`
- **Funciones:** `verbo_sustantivo()`
- **Triggers:** `accion_tabla_evento`
- **Políticas RLS:** `"accion_para_quien"`

### Orden Recomendado en Archivos SQL

1. Comentarios de cabecera (descripción, autor, fecha)
2. Eliminación de objetos existentes (si aplica)
3. Creación de tablas
4. Creación de índices
5. Creación de funciones
6. Creación de triggers
7. Configuración de RLS y políticas
8. Inserción de datos iniciales (si aplica)
9. Comentarios de documentación

## Recursos Adicionales

- [PostgreSQL Style Guide](https://www.sqlstyle.guide/)
- [Supabase Database Guidelines](https://supabase.com/docs/guides/database)
- [SQL Anti-Patterns](https://sql-antipatterns.com/)

---

¿Tienes preguntas? Consulta el [README principal](../README.md) o contacta al equipo de desarrollo.