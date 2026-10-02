USE [TURISMOPERU_ATM];
GO
 
/* =========================================================
   PRUEBAS DE SEGURIDAD Y MÍNIMO PRIVILEGIO
   Base de datos: TURISMOPERU_ATM   |   Esquema: ATM
   ========================================================= */
 
 
/* ---------------------------------------------------------
   PRUEBA 1: ANALISTA PUEDE CONSULTAR
   --------------------------------------------------------- */
EXECUTE AS USER = 'turismo_analista';
 
SELECT USER_NAME() AS UsuarioActual;
SELECT TOP 5 * FROM [ATM].[cliente];
SELECT TOP 5 * FROM [ATM].[reserva];
SELECT TOP 5 * FROM [ATM].[pago];
 
REVERT;
GO
 
 
/* ---------------------------------------------------------
   PRUEBA 2: ANALISTA NO PUEDE MODIFICAR
   SQL Server debe rechazar INSERT y DELETE (error 229).
   Para el informe se puede reemplazar DEFAULT VALUES por un
   INSERT con columnas reales de ATM.pago; el rechazo por
   permisos ocurre antes de validar los datos.
   --------------------------------------------------------- */
EXECUTE AS USER = 'turismo_analista';
 
SELECT USER_NAME() AS UsuarioActual;
 
BEGIN TRY
    INSERT INTO [ATM].[pago] DEFAULT VALUES;
    PRINT 'ERROR DE SEGURIDAD: el analista pudo insertar.';
END TRY
BEGIN CATCH
    PRINT 'INSERT rechazado (esperado): ' + ERROR_MESSAGE();
END CATCH;
 
BEGIN TRY
    DELETE FROM [ATM].[pago] WHERE 1 = 0;
    PRINT 'ERROR DE SEGURIDAD: el analista pudo eliminar.';
END TRY
BEGIN CATCH
    PRINT 'DELETE rechazado (esperado): ' + ERROR_MESSAGE();
END CATCH;
 
SELECT
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'SELECT') AS Puede_SELECT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'INSERT') AS Puede_INSERT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'UPDATE') AS Puede_UPDATE,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'DELETE') AS Puede_DELETE;
 
REVERT;
GO
 
 
/* ---------------------------------------------------------
   PRUEBA 3: VENDEDOR
   Puede consultar e insertar; NO puede eliminar.
   --------------------------------------------------------- */
EXECUTE AS USER = 'turismo_vendedor';
 
SELECT USER_NAME() AS UsuarioActual;
 
SELECT
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'SELECT') AS Cliente_SELECT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'INSERT') AS Cliente_INSERT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'DELETE') AS Cliente_DELETE,
    HAS_PERMS_BY_NAME('ATM.reserva', 'OBJECT', 'SELECT') AS Reserva_SELECT,
    HAS_PERMS_BY_NAME('ATM.reserva', 'OBJECT', 'INSERT') AS Reserva_INSERT,
    HAS_PERMS_BY_NAME('ATM.reserva', 'OBJECT', 'DELETE') AS Reserva_DELETE,
    HAS_PERMS_BY_NAME('ATM.pago',    'OBJECT', 'SELECT') AS Pago_SELECT;
 
BEGIN TRY
    DELETE FROM [ATM].[cliente] WHERE 1 = 0;
    PRINT 'ERROR DE SEGURIDAD: el vendedor pudo eliminar clientes.';
END TRY
BEGIN CATCH
    PRINT 'DELETE cliente rechazado (esperado): ' + ERROR_MESSAGE();
END CATCH;
 
BEGIN TRY
    DELETE FROM [ATM].[reserva] WHERE 1 = 0;
    PRINT 'ERROR DE SEGURIDAD: el vendedor pudo eliminar reservas.';
END TRY
BEGIN CATCH
    PRINT 'DELETE reserva rechazado (esperado): ' + ERROR_MESSAGE();
END CATCH;
 
REVERT;
GO
 
 
/* ---------------------------------------------------------
   PRUEBA 4: VENDEDOR Y ANALISTA NO ADMINISTRAN LA BASE
   Todos los valores deben ser 0.
   --------------------------------------------------------- */
EXECUTE AS USER = 'turismo_vendedor';
 
SELECT
    USER_NAME()                          AS UsuarioActual,
    IS_ROLEMEMBER('db_owner')            AS Es_db_owner,
    IS_ROLEMEMBER('db_securityadmin')    AS Es_securityadmin,
    IS_ROLEMEMBER('db_accessadmin')      AS Es_accessadmin,
    IS_ROLEMEMBER('db_backupoperator')   AS Es_backupoperator;
 
BEGIN TRY
    CREATE USER usuario_prueba WITHOUT LOGIN;
    PRINT 'ERROR DE SEGURIDAD: el vendedor pudo crear usuarios.';
END TRY
BEGIN CATCH
    PRINT 'CREATE USER rechazado (esperado): ' + ERROR_MESSAGE();
END CATCH;
 
REVERT;
GO
 
EXECUTE AS USER = 'turismo_analista';
 
SELECT
    USER_NAME()                          AS UsuarioActual,
    IS_ROLEMEMBER('db_owner')            AS Es_db_owner,
    IS_ROLEMEMBER('db_securityadmin')    AS Es_securityadmin,
    IS_ROLEMEMBER('db_accessadmin')      AS Es_accessadmin,
    IS_ROLEMEMBER('db_backupoperator')   AS Es_backupoperator;
 
REVERT;
GO