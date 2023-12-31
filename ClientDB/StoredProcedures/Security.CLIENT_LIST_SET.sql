USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[CLIENT_LIST_SET]
	@ID		INT,
	@RALL	BIT,
	@RMAN	BIT,
	@RSER	BIT,
	@RORI	BIT,
	@RINC	NVARCHAR(MAX),
	@REXC	NVARCHAR(MAX),
	@WALL	BIT,
	@WMAN	BIT,
	@WSER	BIT,
	@WORI	BIT,
	@WINC	NVARCHAR(MAX),
	@WEXC	NVARCHAR(MAX)

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

		DECLARE @USER	NVARCHAR(128)

		SELECT @USER = name
		FROM sys.database_principals
		WHERE principal_id = @ID

		UPDATE Security.ClientList
		SET LST_ALL = @RALL,
			LST_MANAGER = @RMAN,
			LST_SERVICE = @RSER,
			LST_ORI = @RORI,
			LST_INCLUDE = @RINC,
			LST_EXCLUDE = @REXC
		WHERE LST_USER = @USER AND LST_TYPE = 'READ'

		IF @@ROWCOUNT = 0
			INSERT INTO Security.ClientList(LST_TYPE, LST_USER, LST_ALL, LST_MANAGER, LST_SERVICE, LST_ORI, LST_INCLUDE, LST_EXCLUDE)
				VALUES('READ', @USER, @RALL, @RMAN, @RSER, @RORI, @RINC, @REXC)

		UPDATE Security.ClientList
		SET LST_ALL = @WALL,
			LST_MANAGER = @WMAN,
			LST_SERVICE = @WSER,
			LST_ORI = @WORI,
			LST_INCLUDE = @WINC,
			LST_EXCLUDE = @WEXC
		WHERE LST_USER = @USER AND LST_TYPE = 'WRITE'

		IF @@ROWCOUNT = 0
			INSERT INTO Security.ClientList(LST_TYPE, LST_USER, LST_ALL, LST_MANAGER, LST_SERVICE, LST_ORI, LST_INCLUDE, LST_EXCLUDE)
				VALUES('WRITE', @USER, @WALL, @WMAN, @WSER, @WORI, @WINC, @WEXC)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[CLIENT_LIST_SET] TO rl_security_client_list_u;
GO
