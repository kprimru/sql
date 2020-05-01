USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_LESSON_COUNT_SELECT]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT
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

		SELECT LS_ID, LS_NAME, SS_COUNT
		FROM 
			Subhost.SubhostStudy a INNER JOIN
			Subhost.Lesson ON LS_ID = SS_ID_LESSON 
		WHERE SS_ID_PERIOD = @PR_ID AND SS_ID_SUBHOST = @SH_ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_LESSON_COUNT_SELECT] TO rl_subhost_calc;
GO