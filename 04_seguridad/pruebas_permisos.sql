USE [TURISMOPERU_ATM];
GO

/* =========================================================
   PRUEBAS DE SEGURIDAD Y MÍNIMO PRIVILEGIO
   ========================================================= */


/* ---------------------------------------------------------
   PRUEBA 1: USUARIO ANALISTA
   Debe poder consultar información.
   --------------------------------------------------------- */

EXECUTE AS USER = 'turismo_analista';
GO

SELECT TOP 5 *
FROM [ATM].[cliente];
GO

SELECT TOP 5 *
FROM [ATM].[reserva];
GO

REVERT;
GO


/* ---------------------------------------------------------
   PRUEBA 2: ANALISTA NO DEBE PODER INSERTAR
   --------------------------------------------------------- */

EXECUTE AS USER = 'turismo_analista';
GO

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'SELECT') AS Puede_SELECT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'INSERT') AS Puede_INSERT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'UPDATE') AS Puede_UPDATE,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'DELETE') AS Puede_DELETE;
GO

REVERT;
GO


/* ---------------------------------------------------------
   PRUEBA 3: VENDEDOR
   Puede consultar e insertar en cliente.
   No puede eliminar.
   --------------------------------------------------------- */

EXECUTE AS USER = 'turismo_vendedor';
GO

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'SELECT') AS Puede_SELECT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'INSERT') AS Puede_INSERT,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'UPDATE') AS Puede_UPDATE,
    HAS_PERMS_BY_NAME('ATM.cliente', 'OBJECT', 'DELETE') AS Puede_DELETE;
GO

REVERT;
GO


/* ---------------------------------------------------------
   PRUEBA 4: VENDEDOR NO ES ADMINISTRADOR DE BASE DE DATOS
   --------------------------------------------------------- */

EXECUTE AS USER = 'turismo_vendedor';
GO

SELECT
    USER_NAME() AS UsuarioActual,
    IS_ROLEMEMBER('db_owner') AS Es_db_owner,
    IS_ROLEMEMBER('db_securityadmin') AS Es_securityadmin,
    IS_ROLEMEMBER('db_accessadmin') AS Es_accessadmin;
GO

REVERT;
GO

