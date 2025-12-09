# Policies (Políticas RLS)

Esta carpeta contiene configuraciones de Row Level Security (RLS) y políticas de acceso.

## ¿Qué es Row Level Security (RLS)?

**Row Level Security** es una característica de PostgreSQL que permite controlar qué filas puede ver o modificar cada usuario en una tabla.

En Supabase, RLS es fundamental para:
- Proteger datos sensibles
- Implementar autorización granular
- Separar datos entre usuarios
- Cumplir con regulaciones de privacidad

## Políticas Actuales

### subscribers_rls_disabled
RLS deshabilitado para la tabla subscribers. Ver archivo para justificación completa.

**Razón:** Formulario público de suscripción que requiere inserts sin autenticación.

## Estados de RLS

### RLS Habilitado
```sql
ALTER TABLE nombre_tabla ENABLE ROW LEVEL SECURITY;
```

### RLS Deshabilitado
```sql
ALTER TABLE nombre_tabla DISABLE ROW LEVEL SECURITY;
```

### Verificar Estado
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'nombre_tabla';
```

## Tipos de Políticas

### 1. SELECT - Controlar qué filas se pueden leer
```sql
CREATE POLICY "usuarios_ven_sus_propios_datos"
  ON tabla
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());
```

### 2. INSERT - Controlar qué se puede insertar
```sql
CREATE POLICY "usuarios_pueden_crear_sus_registros"
  ON tabla
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());
```

### 3. UPDATE - Controlar qué se puede actualizar
```sql
CREATE POLICY "usuarios_actualizan_sus_datos"
  ON tabla
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
```

### 4. DELETE - Controlar qué se puede eliminar
```sql
CREATE POLICY "usuarios_eliminan_sus_datos"
  ON tabla
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
```

### 5. ALL - Política para todas las operaciones
```sql
CREATE POLICY "admin_acceso_total"
  ON tabla
  FOR ALL
  TO authenticated
  USING (auth.role() = 'admin');
```

## Roles en Supabase

### anon
- Usuario no autenticado
- Usa la anon key del proyecto
- Típicamente solo SELECT o INSERT público

```sql
CREATE POLICY "permitir_lectura_publica"
  ON tabla
  FOR SELECT
  TO anon
  USING (true);
```

### authenticated
- Usuario autenticado
- Ha hecho login con Supabase Auth
- Acceso a sus propios datos

```sql
CREATE POLICY "usuarios_autenticados"
  ON tabla
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());
```

### service_role
- Rol de servicio
- Bypass RLS automáticamente
- Solo para operaciones del servidor

## Plantilla de Política

```sql
-- ============================================================================
-- RLS Policy: nombre_tabla - descripcion_corta
-- Description: [Explicación detallada de qué protege esta política]
-- Table: nombre_tabla
-- Author: AltoQ Team
-- Date: YYYY-MM-DD
-- ============================================================================

-- ============================================================================
-- JUSTIFICACIÓN
-- ============================================================================
-- [Explica POR QUÉ esta política es necesaria]
-- [Qué escenarios de seguridad cubre]
-- [Qué roles pueden hacer qué]

-- ============================================================================
-- Habilitar RLS
-- ============================================================================

ALTER TABLE nombre_tabla ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- Políticas
-- ============================================================================

-- Política para SELECT
CREATE POLICY "nombre_policy_select"
  ON nombre_tabla
  FOR SELECT
  TO authenticated
  USING (condicion);

-- Política para INSERT
CREATE POLICY "nombre_policy_insert"
  ON nombre_tabla
  FOR INSERT
  TO authenticated
  WITH CHECK (condicion);

-- Política para UPDATE
CREATE POLICY "nombre_policy_update"
  ON nombre_tabla
  FOR UPDATE
  TO authenticated
  USING (condicion_antes)
  WITH CHECK (condicion_despues);

-- Política para DELETE
CREATE POLICY "nombre_policy_delete"
  ON nombre_tabla
  FOR DELETE
  TO authenticated
  USING (condicion);

-- ============================================================================
-- Verificación
-- ============================================================================
-- SELECT * FROM nombre_tabla; -- Como usuario autenticado
-- SELECT * FROM nombre_tabla; -- Como anon

-- ============================================================================
-- Notas
-- ============================================================================
-- [Casos edge, limitaciones, consideraciones especiales]
```

## Funciones de Supabase Auth

Supabase proporciona funciones útiles para políticas:

### auth.uid()
Retorna el UUID del usuario autenticado actual
```sql
USING (user_id = auth.uid())
```

### auth.role()
Retorna el rol del usuario ('anon', 'authenticated')
```sql
USING (auth.role() = 'authenticated')
```

### auth.email()
Retorna el email del usuario autenticado
```sql
USING (email = auth.email())
```

### auth.jwt()
Accede a claims personalizados del JWT
```sql
USING ((auth.jwt() -> 'user_metadata' ->> 'role') = 'admin')
```

## Ejemplos Comunes

### 1. Acceso Público a Lectura
```sql
-- policies/public_read_subscribers.sql
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "permitir_lectura_publica"
  ON subscribers
  FOR SELECT
  TO anon, authenticated
  USING (true);
```

### 2. Usuarios Ven Solo Sus Datos
```sql
-- policies/users_own_data.sql
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "usuarios_ven_su_perfil"
  ON user_profiles
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "usuarios_actualizan_su_perfil"
  ON user_profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());
```

### 3. Admin Acceso Total
```sql
-- policies/admin_full_access.sql
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_acceso_total"
  ON subscribers
  FOR ALL
  TO authenticated
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );
```

### 4. Insert Público con Restricciones
```sql
-- policies/public_insert_subscribers.sql
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;

-- Permitir inserts anónimos
CREATE POLICY "permitir_suscripcion_publica"
  ON subscribers
  FOR INSERT
  TO anon
  WITH CHECK (
    email IS NOT NULL
    AND terms_accepted = true
  );

-- Solo admins pueden leer
CREATE POLICY "solo_admin_puede_leer"
  ON subscribers
  FOR SELECT
  TO authenticated
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );
```

### 5. Datos Compartidos en Organización
```sql
-- policies/organization_shared_data.sql
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "usuarios_de_misma_org"
  ON documents
  FOR SELECT
  TO authenticated
  USING (
    organization_id IN (
      SELECT organization_id
      FROM user_organizations
      WHERE user_id = auth.uid()
    )
  );
```

### 6. Soft Delete - Solo Lectura de Activos
```sql
-- policies/only_active_records.sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "solo_posts_activos"
  ON posts
  FOR SELECT
  TO authenticated
  USING (deleted_at IS NULL);

CREATE POLICY "admin_ve_todos"
  ON posts
  FOR SELECT
  TO authenticated
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );
```

## Gestión de Políticas

### Crear Política
```sql
CREATE POLICY nombre_policy ON tabla ...
```

### Eliminar Política
```sql
DROP POLICY IF EXISTS nombre_policy ON tabla;
```

### Listar Políticas
```sql
SELECT schemaname, tablename, policyname, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'nombre_tabla';
```

### Deshabilitar Temporalmente
```sql
-- Opción 1: Deshabilitar RLS completamente
ALTER TABLE tabla DISABLE ROW LEVEL SECURITY;

-- Opción 2: Usar service_role key que bypasea RLS
```

## Mejores Prácticas

1. **Documentar Justificación**: Siempre explica POR QUÉ RLS está habilitado o deshabilitado

2. **Principio de Menor Privilegio**: Solo da acceso necesario
   - ❌ `USING (true)` para todo
   - ✅ `USING (user_id = auth.uid())`

3. **Testing**: Prueba con diferentes roles
   ```sql
   -- Como anon
   SET ROLE anon;
   SELECT * FROM tabla;

   -- Como authenticated
   SET ROLE authenticated;
   SELECT * FROM tabla;
   ```

4. **Performance**: Las políticas agregan WHERE clauses
   - Usa índices en columnas usadas en USING
   - Evita políticas muy complejas

5. **Separación**: Un archivo por tabla o grupo lógico

6. **Versionado**: Versiona las políticas junto con migraciones

## Debugging RLS

### Ver qué políticas se aplican
```sql
SELECT * FROM pg_policies WHERE tablename = 'subscribers';
```

### Verificar si RLS está habilitado
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'subscribers';
```

### Probar como usuario anónimo
```sql
-- En Supabase, usa la anon key
-- En psql:
SET ROLE anon;
SELECT * FROM tabla;
RESET ROLE;
```

### Bypass RLS temporalmente (solo admins)
```sql
SET ROLE service_role;
-- O en Supabase, usa la service_role key
```

## Casos de Uso Comunes

### SaaS Multi-tenant
```sql
-- Cada usuario solo ve datos de su organización
USING (organization_id = (
  SELECT organization_id FROM users WHERE id = auth.uid()
))
```

### Contenido Público/Privado
```sql
-- Contenido público para todos, privado solo para el autor
USING (
  is_public = true
  OR author_id = auth.uid()
)
```

### Roles Personalizados
```sql
-- Admin, Editor, Viewer
USING (
  user_role IN ('admin', 'editor')
  OR (user_role = 'viewer' AND operation = 'SELECT')
)
```

---

Para más información:
- [Documentación de RLS en PostgreSQL](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Guía de RLS en Supabase](https://supabase.com/docs/guides/auth/row-level-security)
- [README principal](../README.md)