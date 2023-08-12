USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[VISIT_PAY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[VISIT_PAY_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[VISIT_PAY_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT VisitPayID, VisitPayBegin, VisitPayEnd, VisitPayValue
		FROM dbo.VisitPayTable
		ORDER BY VisitPayBegin DESC, VisitPayValue

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[VISIT_PAY_SELECT] TO rl_visit_pay_r;
GO
