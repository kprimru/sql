USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTROL_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTROL_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTROL_CHECK]
	@CLIENT		INT,
	@CONTROL	BIT = NULL OUTPUT,
	@ID			INT = NULL
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

		SET @CONTROL = NULL

		IF @ID IS NULL
		BEGIN
			SELECT TOP 1 @CONTROL = 1
			FROM dbo.ClientControl
			WHERE CC_ID_CLIENT = @CLIENT
				--AND CC_READ_DATE IS NULL
				AND CC_REMOVE_DATE IS NULL
				--AND (CC_BEGIN IS NULL OR CC_BEGIN <= GETDATE())
			ORDER BY CC_DATE DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @CONTROL = 1
			FROM dbo.ClientControl
			WHERE CC_ID = @ID
				AND CC_REMOVE_DATE IS NULL
		END

		--RAISERROR('Ошибканамэ!', 15, 1)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTROL_CHECK] TO rl_client_control_r;
GO
