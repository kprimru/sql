USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_LESSON_POSITION_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_LESSON_POSITION_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_LESSON_POSITION_SELECT]
	@ACTIVE BIT = NULL
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

		SELECT LP_ID, LP_NAME, LP_ACTIVE
		FROM Subhost.LessonPosition
		WHERE LP_ACTIVE = ISNULL(@ACTIVE, LP_ACTIVE)
		ORDER BY LP_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_LESSON_POSITION_SELECT] TO rl_subhost_lesson_position_r;
GO
