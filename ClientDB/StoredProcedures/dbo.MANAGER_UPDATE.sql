USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[MANAGER_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[MANAGER_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[MANAGER_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@LOGIN	VARCHAR(100),
	@FULL	VARCHAR(250)
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

		UPDATE dbo.ManagerTable
		SET ManagerName = @NAME,
			ManagerLogin = @LOGIN,
			ManagerFullName = @FULL
		WHERE ManagerID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[MANAGER_UPDATE] TO rl_personal_manager_u;
GO
