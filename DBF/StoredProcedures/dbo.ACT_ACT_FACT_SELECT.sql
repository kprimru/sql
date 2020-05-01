USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_ACT_FACT_SELECT]
	@actid	INT
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

		SELECT
			AFM_DATE,
			PR_MONTH AS PR_NAME,
			ORG_SHORT_NAME,
			CL_PSEDO, CL_FULL_NAME,
			(SELECT SUM(AD_TOTAL_PRICE) FROM dbo.ActFactDetailTable WHERE AFD_ID_AFM = AFM_ID) AS AFM_TOTAL_PRICE
		FROM dbo.ActFactMasterTable
		WHERE ACT_ID = @actid
		ORDER BY AFM_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[ACT_ACT_FACT_SELECT] TO rl_act_p;
GO