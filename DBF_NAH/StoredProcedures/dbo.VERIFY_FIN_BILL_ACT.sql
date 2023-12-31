USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[VERIFY_FIN_BILL_ACT]
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

		SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE, BD_TOTAL_PRICE, AD_TOTAL_PRICE
		FROM
			(
				SELECT
					BL_ID_CLIENT,
					BL_ID_PERIOD,
					BD_ID_DISTR,
					BD_TOTAL_PRICE, AD_TOTAL_PRICE
				FROM

					(
						SELECT
							BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, BD_TOTAL_PRICE
						FROM
							dbo.BillTable a INNER JOIN
							dbo.BillDistrTable b ON BL_ID=BD_ID_BILL
					)
					AS Bills
					INNER JOIN
					(
						SELECT
							ACT_ID_CLIENT, AD_ID_PERIOD, AD_ID_DISTR, AD_TOTAL_PRICE
						FROM
							dbo.ActTable a INNER JOIN
							dbo.ActDistrTable b ON ACT_ID=AD_ID_ACT
					)
					AS Acts
					ON Bills.BL_ID_CLIENT=Acts.ACT_ID_CLIENT AND Bills.BL_ID_PERIOD=AD_ID_PERIOD
						AND Bills.BD_ID_DISTR=Acts.AD_ID_DISTR

				WHERE BD_TOTAL_PRICE <> AD_TOTAL_PRICE


				UNION ALL

				SELECT
					BL_ID_CLIENT,
					BL_ID_PERIOD,
					BD_ID_DISTR,
					BD_TOTAL_PRICE, CSD_TOTAL_PRICE
				FROM

					(
						SELECT
							BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, BD_TOTAL_PRICE
						FROM
							dbo.BillTable a INNER JOIN
							dbo.BillDistrTable b ON BL_ID=BD_ID_BILL
					)
					AS Bills
					INNER JOIN
					(
						SELECT
							CSG_ID_CLIENT, CSD_ID_PERIOD, CSD_ID_DISTR, CSD_TOTAL_PRICE
						FROM
							dbo.ConsignmentTable a INNER JOIN
							dbo.ConsignmentDetailTable b ON CSG_ID = CSD_ID_CONS
					)
					AS Cons
					ON Bills.BL_ID_CLIENT = CSG_ID_CLIENT
						AND Bills.BL_ID_PERIOD = CSD_ID_PERIOD
						AND Bills.BD_ID_DISTR = CSD_ID_DISTR

				WHERE BD_TOTAL_PRICE <> CSD_TOTAL_PRICE

			) AS o_O INNER JOIN
			dbo.ClientTable ON CL_ID = BL_ID_CLIENT INNER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR INNER JOIN
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
		ORDER BY CL_PSEDO, DIS_STR, PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[VERIFY_FIN_BILL_ACT] TO rl_audit_fin;
GO
