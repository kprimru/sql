USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_PREPARE]
	@CLIENT	INT,
	@TEXT	VARCHAR(100) = NULL OUTPUT,
	@COLOR	INT = NULL OUTPUT
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

		SET @TEXT = NULL

		SET @COLOR = 0

		IF EXISTS
			(
				SELECT *
				FROM dbo.ClientDutyTable
				WHERE ClientID = @CLIENT
					AND ClientDutyComplete = 0
			)
			SET @COLOR = 2

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_PREPARE] TO rl_client_duty_r;
GO
