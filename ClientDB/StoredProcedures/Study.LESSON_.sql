USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Study].[LESSON_]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Study].[LESSON_]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Study].[LESSON_]
	@TEACHER	NVARCHAR(128),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TXT		NVARCHAR(256)
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

		SELECT ID, DATE, TEACHER, THEME, NOTE
		FROM Study.Lesson
		WHERE STATUS = 1
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE <= @END OR @END IS NULL)
			AND (TEACHER = @TEACHER OR @TEACHER IS NULL)
			AND (THEME LIKE @TXT OR NOTE LIKE @TXT OR @TXT IS NULL)
		ORDER BY DATE DESC, TEACHER, THEME, NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
