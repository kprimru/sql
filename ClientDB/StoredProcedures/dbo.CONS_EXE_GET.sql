USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONS_EXE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONS_EXE_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CONS_EXE_GET]
	@ID	INT
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

		SELECT ConsExeVersionName, ConsExeVersionActive, ConsExeVersionBegin, ConsExeVersionEnd
		FROM dbo.ConsExeVersionTable
		WHERE ConsExeVersionID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CONS_EXE_GET] TO rl_cons_exe_r;
GO
