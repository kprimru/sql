﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[LOCK_CLEAR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[LOCK_CLEAR]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[LOCK_CLEAR]
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

		DELETE
		FROM dbo.Locks
		WHERE NOT EXISTS
			(
				SELECT *
				FROM sys.dm_exec_sessions
				WHERE	LC_SPID		=	session_id AND
						LC_HOST		=	host_name AND
						LC_LOGIN		=	original_login_name AND
						LC_LOGIN_TIME	=	login_time  
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
GRANT EXECUTE ON [dbo].[LOCK_CLEAR] TO rl_lock_d;
GO
