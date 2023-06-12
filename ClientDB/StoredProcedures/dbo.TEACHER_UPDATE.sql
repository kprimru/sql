USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TEACHER_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TEACHER_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TEACHER_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(250),
	@LOGIN	VARCHAR(100),
	@REPORT	BIT,
	@NORMA	DECIMAL(4, 2)
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

		UPDATE dbo.TeacherTable
		SET TeacherName = @NAME,
			TeacherLogin = @LOGIN,
			TeacherReport = @REPORT,
			TeacherNorma = @NORMA
		WHERE TeacherID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TEACHER_UPDATE] TO rl_personal_teacher_u;
GO
