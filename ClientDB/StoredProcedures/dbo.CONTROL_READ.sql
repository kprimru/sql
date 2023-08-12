USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTROL_READ]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTROL_READ]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CONTROL_READ]
	@CC_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Setting_CONTROL_LOGIN	Bit;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Setting_CONTROL_LOGIN = Cast([System].[Setting@Get]('CONTROL_LOGIN') AS Bit);

		IF @Setting_CONTROL_LOGIN = 0
		BEGIN
			UPDATE dbo.ClientControl
			SET CC_READER = ORIGINAL_LOGIN(),
				CC_READ_DATE = GETDATE()
			WHERE CC_ID = @CC_ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONTROL_READ] TO rl_client_control_read;
GO
