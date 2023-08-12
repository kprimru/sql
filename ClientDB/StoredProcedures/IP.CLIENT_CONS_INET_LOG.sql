﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[IP].[CLIENT_CONS_INET_LOG]', 'P ') IS NULL EXEC('CREATE PROCEDURE [IP].[CLIENT_CONS_INET_LOG]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [IP].[CLIENT_CONS_INET_LOG]
	@FILE	NVarChar(512),
	@SERVER	Int
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

		SELECT REPLACE(LF_TEXT, CHAR(10), CHAR(10) + CHAR(13) + CHAR(10) + CHAR(13)) AS LF_TEXT
		FROM IP.LogFileView
		WHERE FL_NAME = @FILE
			AND FL_ID_SERVER = @SERVER;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [IP].[CLIENT_CONS_INET_LOG] TO rl_client_ip;
GO
