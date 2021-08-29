USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_FINANCING_GET]
	@dfid INT
AS
BEGIN
	SET NOCOUNT ON

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
			DF_ID,
			DIS_STR, DIS_ID,
			SN_ID, SN_NAME,
			NULL AS TT_ID, NULL AS TT_NAME,
			SST_ID, SST_CAPTION,
			PP_ID, PP_NAME,
			DF_DISCOUNT, DF_COEF, DF_FIXED_PRICE, DF_MON_COUNT,
			PR_ID, PR_DATE,
			DF_DEBT	, DF_END, DF_BEGIN, DF_EXPIRE,
			COP_ID, COP_NAME, DF_NAME
		FROM
			dbo.DistrFinancingTable a LEFT OUTER JOIN
			dbo.DistrView b WITH(NOEXPAND) ON a.DF_ID_DISTR = b.DIS_ID LEFT OUTER JOIN
			dbo.SystemNetTable c ON c.SN_ID = a.DF_ID_NET LEFT OUTER JOIN
			dbo.SystemTypeTable e ON e.SST_ID = a.DF_ID_TYPE LEFT OUTER JOIN
			dbo.PriceTable f ON f.PP_ID = a.DF_ID_PRICE LEFT OUTER JOIN
			dbo.PeriodTable g ON g.PR_ID = a.DF_ID_PERIOD LEFT OUTER JOIN
			dbo.ContractPayTable h ON h.COP_ID = a.DF_ID_PAY
		WHERE DF_ID = @dfid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_GET] TO rl_distr_financing_r;
GO