USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_REPORT_COMPLECT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_REPORT_COMPLECT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[RISK_REPORT_COMPLECT_SELECT]
	@Client_Id	Int
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

		SELECT DISTINCT D.[Complect]
		FROM [dbo].[RiskReportDetail]	AS D
		WHERE D.[ClientID] = @Client_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RISK_REPORT_COMPLECT_SELECT] TO rl_risk;
GO
