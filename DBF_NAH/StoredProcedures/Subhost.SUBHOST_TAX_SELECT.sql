USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_TAX_SELECT]
	@PR_ID	SMALLINT = NULL
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

		DECLARE @DATE SMALLDATETIME;

		SELECT @DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		SELECT
			a.TX_NAME AS CTX_NAME, a.TX_PERCENT AS CTX_PERCENT, a.TX_CAPTION + '%' AS CTX_CAPTION,
			b.TX_NAME AS PTX_NAME, b.TX_PERCENT AS PTX_PERCENT
		FROM
		(
			SELECT TX_NAME, TX_PERCENT
			FROM dbo.TaxTable
			WHERE TX_PERCENT = 10
		) b
		CROSS JOIN
		(
			SELECT t.TX_NAME, t.TX_PERCENT, t.TX_CAPTION
			FROM dbo.TaxDefaultSelect(@DATE) d
			INNER JOIN dbo.TaxTable t ON d.TX_ID = t.TX_ID
		) a

		/*
		SELECT
			a.TX_NAME AS CTX_NAME, a.TX_PERCENT AS CTX_PERCENT,
			b.TX_NAME AS PTX_NAME, b.TX_PERCENT AS PTX_PERCENT
		FROM dbo.TaxTable a, dbo.TaxTable b
		WHERE a.TX_ID = 1 AND b.TX_ID = 2
		*/

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_TAX_SELECT] TO rl_subhost_calc;
GO
