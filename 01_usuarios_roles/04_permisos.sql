USE [TURISMOPERU_ATM];
GO
 
/* =========================================================
   04_permisos.sql
   Asignación de permisos con mínimo privilegio
   Base de datos: TURISMOPERU_ATM   |   Esquema: ATM
   ========================================================= */
 
 
/* ---------------------------------------------------------
   0. Membresía de usuarios en roles
   (si ya lo hiciste en 03_roles.sql, no se duplica)
   --------------------------------------------------------- */
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = 'rol_vendedor' AND u.name = 'turismo_vendedor')
    ALTER ROLE rol_vendedor ADD MEMBER turismo_vendedor;
GO
 
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals u ON u.principal_id = rm.member_principal_id
    WHERE r.name = 'rol_analista' AND u.name = 'turismo_analista')
    ALTER ROLE rol_analista ADD MEMBER turismo_analista;
GO
 
 
/* ---------------------------------------------------------
   1. rol_vendedor
   Puede: SELECT/INSERT cliente, SELECT/INSERT reserva,
          SELECT alojamiento, SELECT habitacion
   No puede: DELETE cliente, DELETE reserva
   --------------------------------------------------------- */
GRANT SELECT, INSERT ON [ATM].[cliente]      TO rol_vendedor;
GRANT SELECT, INSERT ON [ATM].[reserva]      TO rol_vendedor;
GRANT SELECT         ON [ATM].[alojamiento]  TO rol_vendedor;
GRANT SELECT         ON [ATM].[habitacion]   TO rol_vendedor;
GO
 
DENY DELETE ON [ATM].[cliente] TO rol_vendedor;
DENY DELETE ON [ATM].[reserva] TO rol_vendedor;
GO
 
 
/* ---------------------------------------------------------
   2. rol_analista
   Puede: solo SELECT en 7 tablas
   No puede: INSERT, UPDATE, DELETE en el esquema ATM
   --------------------------------------------------------- */
GRANT SELECT ON [ATM].[cliente]          TO rol_analista;
GRANT SELECT ON [ATM].[reserva]          TO rol_analista;
GRANT SELECT ON [ATM].[pago]             TO rol_analista;
GRANT SELECT ON [ATM].[alojamiento]      TO rol_analista;
GRANT SELECT ON [ATM].[habitacion]       TO rol_analista;
GRANT SELECT ON [ATM].[paquete]          TO rol_analista;
GRANT SELECT ON [ATM].[lugar_turistico]  TO rol_analista;
GO
 
DENY INSERT, UPDATE, DELETE ON SCHEMA::[ATM] TO rol_analista;
GO
 
 
/* ---------------------------------------------------------
   3. Ninguno de los dos roles administra la base
   (usuarios, roles y backups)
   --------------------------------------------------------- */
DENY ALTER ANY USER      TO rol_vendedor, rol_analista;
DENY ALTER ANY ROLE      TO rol_vendedor, rol_analista;
DENY BACKUP DATABASE     TO rol_vendedor, rol_analista;
DENY BACKUP LOG          TO rol_vendedor, rol_analista;
GO
 
 
/* ---------------------------------------------------------
   4. Verificación: permisos efectivos por rol
   (útil para la captura evidencias/permisos.png)
   --------------------------------------------------------- */
SELECT
    pr.name                                    AS Rol,
    dp.state_desc                              AS Estado,
    dp.permission_name                         AS Permiso,
    dp.class_desc                              AS Clase,
    COALESCE(OBJECT_NAME(dp.major_id),
             SCHEMA_NAME(dp.major_id))         AS Objeto
FROM sys.database_permissions dp
JOIN sys.database_principals pr ON pr.principal_id = dp.grantee_principal_id
WHERE pr.name IN ('rol_vendedor', 'rol_analista')
ORDER BY pr.name, dp.state_desc, dp.permission_name;
GO