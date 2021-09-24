USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------



ALTER PROCEDURE [dbo].[BL_GET_USERROLES]
WITH EXECUTE AS OWNER
AS
BEGIN
SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
		SELECT u.NAME as UserName,
		u.type, s.name as LoginName,
		COALESCE((SELECT 1 FROM sys.database_role_members sr
		WHERE (sr.member_principal_id=u.principal_id)and
		(sr.role_principal_id=(SELECT principal_id from sys.database_principals
		where ([type]='R')and([name]='BL_READER')))), 0) as R_READER,
		COALESCE((SELECT 1 FROM sys.database_role_members sr
		WHERE (sr.member_principal_id=u.principal_id)and
		(sr.role_principal_id=(SELECT principal_id from sys.database_principals
		where ([type]='R')and([name]='BL_EDITOR')))), 0) as R_EDITOR,
		COALESCE((SELECT 1 FROM sys.database_role_members sr
		WHERE (sr.member_principal_id=u.principal_id)and
		(sr.role_principal_id=(SELECT principal_id from sys.database_principals
		where ([type]='R')and([name]='BL_RGT')))), 0) as R_RGT,
		COALESCE((SELECT 1 FROM sys.database_role_members sr
		WHERE (sr.member_principal_id=u.principal_id)and
		(sr.role_principal_id=(SELECT principal_id from sys.database_principals
		where ([type]='R')and([name]='BL_PARAM')))), 0) as R_PARAM,
		COALESCE((SELECT 1 FROM sys.database_role_members sr
		WHERE (sr.member_principal_id=u.principal_id)and
		(sr.role_principal_id=(SELECT principal_id from sys.database_principals
		where ([type]='R')and([name]='BL_ADMIN')))), 0) as R_ADMIN,
		COALESCE((SELECT 1 FROM sys.database_role_members sr
		WHERE (sr.member_principal_id=u.principal_id)and
		(sr.role_principal_id=(SELECT principal_id from sys.database_principals
		where ([type]='R')and([name]='db_owner')))), 0) as R_OWNER
		FROM
		sys.database_principals AS u
		LEFT JOIN sys.server_principals AS s ON s.sid = u.sid
		where ((u.type='U')OR(u.type='G'))and(u.NAME<>'dbo')
		order by u.NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[BL_GET_USERROLES] TO BL_ADMIN;
GO
