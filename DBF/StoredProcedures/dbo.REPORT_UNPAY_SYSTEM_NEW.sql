USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[REPORT_UNPAY_SYSTEM_NEW]
	@prid SMALLINT
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
			CL_ID, CL_PSEDO,
			SYS_NAME, DIS_ID, DIS_STR,
			P.PR_DATE,
			BD_TOTAL_PRICE, ISNULL(ID_PRICE, 0) AS ID_PRICE,
			(
				SELECT COUNT(*)
				FROM dbo.ActIXView WITH(NOEXPAND)
					/*
					dbo.ActTable INNER JOIN
					dbo.ActDistrTable ON ACT_ID = AD_ID_ACT
					*/
				WHERE ACT_ID_CLIENT = CL_ID
					AND AD_ID_DISTR = DIS_ID
					AND AD_ID_PERIOD = PR_ID
			) AS ACT_CLOSE
		FROM
			dbo.ClientTable INNER JOIN
			dbo.ClientDistrTable ON CL_ID = CD_ID_CLIENT INNER JOIN
			dbo.DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
			--DistrServiceStatusTable ON DSS_ID = CD_ID_SERVICE INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CD_ID_DISTR INNER JOIN
			dbo.BillIXView WITH(NOEXPAND) ON BL_ID_CLIENT = CL_ID AND BD_ID_DISTR = DIS_ID INNER JOIN
			/*
			dbo.BillTable ON BL_ID_CLIENT = CL_ID INNER JOIN
			dbo.BillDistrTable ON BD_ID_BILL = BL_ID
							AND	BD_ID_DISTR = DIS_ID INNER JOIN
			*/
			dbo.PeriodTable P ON PR_ID = BL_ID_PERIOD INNER JOIN
			dbo.RegNodeFullTable ON RN_DISTR_NUM = DIS_NUM
									AND RN_COMP_NUM = DIS_COMP_NUM
									AND RN_ID_SYSTEM = SYS_ID INNER JOIN
			dbo.SubhostTable ON SH_ID = RN_ID_SUBHOST INNER JOIN
			dbo.DistrStatusTable ON DS_ID = RN_ID_STATUS LEFT OUTER JOIN
			dbo.IncomeIXView WITH(NOEXPAND) ON IN_ID_CLIENT = CL_ID
											AND ID_ID_DISTR = DIS_ID
											AND ID_ID_PERIOD = PR_ID
			/*
			(
				SELECT IN_ID_CLIENT, ID_ID_DISTR, ID_ID_PERIOD, SUM(ID_PRICE) AS ID_PRICE
				FROM dbo.IncomeIXView WITH(NOEXPAND)
					/*
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
					*/
				GROUP BY IN_ID_CLIENT, ID_ID_DISTR, ID_ID_PERIOD
			) AS dt ON IN_ID_CLIENT = CL_ID
				AND ID_ID_DISTR = DIS_ID
				AND ID_ID_PERIOD = PR_ID
			*/
		WHERE BD_TOTAL_PRICE > ISNULL(ID_PRICE, 0)
			AND DS_REG = 0
			AND SH_SUBHOST = 0
			/*BD_TOTAL_PRICE >
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID
				WHERE IN_ID_CLIENT = CL_ID
					AND ID_ID_DISTR = DIS_ID
					AND ID_ID_PERIOD = PR_ID
			), 0) */
			AND PR_ID <= @prid
			AND DSS_REPORT = 1

		ORDER BY SYS_ORDER, CL_PSEDO, CL_ID, DIS_STR, PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
