USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[VISIT_PAY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[VISIT_PAY_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[VISIT_PAY_UPDATE]
	@ID	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@VALUE	MONEY
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

		UPDATE dbo.VisitPayTable
		SET VisitPayBegin = @BEGIN,
			VisitPayEnd = @END,
			VisitPayValue = @VALUE
		WHERE VisitPayID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[VISIT_PAY_UPDATE] TO rl_visit_pay_u;
GO
