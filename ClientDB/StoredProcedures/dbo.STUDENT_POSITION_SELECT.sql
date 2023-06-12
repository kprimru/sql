USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDENT_POSITION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDENT_POSITION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDENT_POSITION_SELECT]
	@FILTER	VARCHAR(100) = NULL OUTPUT
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

		SELECT StudentPositionID, StudentPositionName
		FROM dbo.StudentPositionTable
		WHERE @FILTER IS NULL
			OR StudentPositionName LIKE @FILTER
		ORDER BY StudentPositionName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDENT_POSITION_SELECT] TO rl_student_position_r;
GO
