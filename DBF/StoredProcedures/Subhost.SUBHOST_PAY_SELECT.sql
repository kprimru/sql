USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_PAY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_PAY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PAY_SELECT]
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

		SELECT
			SHP_ID, SHP_ID_SUBHOST AS SH_ID, SHP_DATE, SHP_SUM, SHP_COMMENT,
			ORG_ID, ORG_PSEDO, PR_ID, PR_DATE
		FROM
			Subhost.SubhostPay INNER JOIN
			Subhost.SubhostPayDetail ON SPD_ID_PAY = SHP_ID INNER JOIN
			dbo.OrganizationTable ON ORG_ID = SHP_ID_ORG INNER JOIN
			dbo.PeriodTable ON PR_ID = SPD_ID_PERIOD
		WHERE SHP_ID_SUBHOST = @SH_ID
		ORDER BY SHP_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PAY_SELECT] TO rl_subhost_calc;
GO
