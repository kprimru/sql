USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DUTY_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DUTY_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DUTY_INSERT]
	@NAME	VARCHAR(100),
	@LOGIN	VARCHAR(100),
	@ACTIVE	BIT,
	@ID	INT = NULL OUTPUT
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

		INSERT INTO dbo.DutyTable(DutyName, DutyLogin, DutyActive)
			VALUES(@NAME, @LOGIN, @ACTIVE)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DUTY_INSERT] TO rl_personal_duty_i;
GO
