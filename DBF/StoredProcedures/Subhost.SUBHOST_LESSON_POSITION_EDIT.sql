USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_LESSON_POSITION_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_LESSON_POSITION_EDIT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_LESSON_POSITION_EDIT]
	@LP_ID	INT,
	@LP_NAME	VARCHAR(50),
	@LP_ORDER	SMALLINT,
	@ACTIVE	BIT
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

		UPDATE Subhost.LessonPosition
		SET LP_NAME = @LP_NAME,
			LP_ORDER = @LP_ORDER,
			LP_ACTIVE = @ACTIVE
		WHERE LP_ID = @LP_ID

		UPDATE dbo.FieldTable
		SET FL_CAPTION = @LP_NAME
		WHERE FL_NAME = 'LP_NAME_' + CONVERT(VARCHAR(10), @LP_ID)

		UPDATE dbo.FieldTable
		SET FL_CAPTION = @LP_NAME + ' цена'
		WHERE FL_NAME = 'SLP_PRICE_' + CONVERT(VARCHAR(10), @LP_ID)

		UPDATE dbo.FieldTable
		SET FL_CAPTION = @LP_NAME + ' сумма'
		WHERE FL_NAME = 'SLP_SUM_' + CONVERT(VARCHAR(10), @LP_ID)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_LESSON_POSITION_EDIT] TO rl_subhost_lesson_position_w;
GO
