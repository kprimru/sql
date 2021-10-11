USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ROLES_SELECT]
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

	    SELECT UPPER(rl.NAME) AS RL_NAME
	    FROM
		    sys.database_principals AS us INNER JOIN
		    sys.database_role_members AS rm ON rm.member_principal_id = us.principal_id INNER JOIN
		    sys.database_principals AS rl ON rm.role_principal_id = rl.principal_id INNER JOIN
		    sys.server_principals AS lg ON lg.sid = us.sid
	    WHERE us.name = ORIGINAL_LOGIN()
	    ORDER BY RL_NAME

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ROLES_SELECT] TO rl_common;
GO
