USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[___CLEAR_LOGON_USERS]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		DELETE a
		FROM Security.LogonUsers a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM sys.dm_exec_sessions b
				WHERE a.SPID = b.session_id
					AND a.[HOST_NAME] = b.[host_name]
					AND a.LOGIN_NAME = b.login_name
					AND a.LOGIN_TIME = b.login_time
					AND a.HOST_PROCESS_ID = b.host_process_id
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
