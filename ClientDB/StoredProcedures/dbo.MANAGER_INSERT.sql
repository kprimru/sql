USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[MANAGER_INSERT]
	@NAME	VARCHAR(100),
	@LOGIN	VARCHAR(100),
	@FULL	VARCHAR(250),
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

		INSERT INTO dbo.ManagerTable(ManagerName, ManagerLogin, ManagerFullName)
			VALUES(@NAME, @LOGIN, @FULL)

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
GRANT EXECUTE ON [dbo].[MANAGER_INSERT] TO rl_personal_manager_i;
GO
