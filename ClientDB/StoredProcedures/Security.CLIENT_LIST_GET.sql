USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[CLIENT_LIST_GET]
	@ID	INT
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

		SELECT
			@ID AS US_ID,
			r.LST_USER,
			r.LST_ALL AS LST_RALL, r.LST_MANAGER AS LST_RMANAGER, r.LST_SERVICE AS LST_RSERVICE, r.LST_ORI AS LST_RORI,
			w.LST_ALL AS LST_WALL, w.LST_MANAGER AS LST_WMANAGER, w.LST_SERVICE AS LST_WSERVICE, w.LST_ORI AS LST_WORI,
			r.LST_INCLUDE AS LST_RINCLUDE, r.LST_EXCLUDE AS LST_REXCLUDE,
			w.LST_INCLUDE AS LST_WINCLUDE, w.LST_EXCLUDE AS LST_WEXCLUDE
		FROM
			(
				SELECT LST_USER, LST_ALL, LST_MANAGER, LST_SERVICE, LST_ORI, LST_INCLUDE, LST_EXCLUDE
				FROM
					Security.ClientList
					INNER JOIN sys.database_principals ON name = LST_USER
				WHERE principal_id = @id AND LST_TYPE = 'READ'
			) AS r INNER JOIN
			(
				SELECT LST_USER, LST_ALL, LST_MANAGER, LST_SERVICE, LST_ORI, LST_INCLUDE, LST_EXCLUDE
				FROM
					Security.ClientList
					INNER JOIN sys.database_principals ON name = LST_USER
				WHERE principal_id = @id AND LST_TYPE = 'WRITE'
			) AS w ON r.LST_USER = w.LST_USER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Security].[CLIENT_LIST_GET] TO rl_security_client_list_u;
GO
