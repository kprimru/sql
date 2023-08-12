USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[USER_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[USER_CHECK]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[USER_CHECK]
	@USER   VARCHAR(128),
	@LOGIN   VARCHAR(128),
    @OKUSER INT = 0 OUTPUT,
    @OKLOGIN INT = 0 OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @OKLOGIN=0;
		SET @OKUSER=0;
		IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = @USER) SET @OKUSER=1
		IF NOT EXISTS (SELECT * FROM sys.database_principals AS u
		   LEFT OUTER JOIN sys.server_principals AS s ON s.sid = u.sid
		   WHERE (Upper(s.name)=Upper(@LOGIN))) SET @OKLOGIN=1

		  EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[USER_CHECK] TO BL_ADMIN;
GO
