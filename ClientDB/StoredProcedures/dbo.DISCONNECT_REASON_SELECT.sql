USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISCONNECT_REASON_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISCONNECT_REASON_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[DISCONNECT_REASON_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT DR_ID, DR_NAME
		FROM dbo.DisconnectReason
		WHERE @FILTER IS NULL
			OR DR_NAME LIKE @FILTER
		ORDER BY DR_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISCONNECT_REASON_SELECT] TO rl_disconnect_reason_r;
GO
