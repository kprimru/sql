USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_FINANCING_ALERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_FINANCING_ALERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_FINANCING_ALERT]
	@DATE	SMALLDATETIME
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

		IF @DATE IS NULL
			SET @DATE = DATEADD(MONTH, 1, GETDATE())

		SELECT b.CL_ID, b.CL_PSEDO, DIS_STR, DF_FIXED_PRICE, DF_DISCOUNT, DF_END, SST_CAPTION, COUR_NAME
		FROM
			dbo.DistrFinancingView a
			INNER JOIN dbo.ClientTable b ON a.CD_ID_CLIENT = CL_ID
			LEFT OUTER JOIN dbo.ClientCourView c ON c.CL_ID = b.CL_ID
		WHERE DSS_REPORT = 1
			--AND (ISNULL(DF_FIXED_PRICE, 0) <> 0 OR ISNULL(DF_DISCOUNT, 0) <> 0)
			AND ((DF_END <= @DATE) OR DF_END IS NULL)
			AND DIS_STR NOT LIKE 'ГК%'
		ORDER BY COUR_NAME, CL_PSEDO, SYS_ORDER, DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_ALERT] TO rl_distr_financing_alert;
GO
