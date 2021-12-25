USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:
*/
ALTER PROCEDURE [dbo].[ACT_FULL_SELECT]
	@periodid SMALLINT,
	@soid SMALLINT,
	@preview BIT = 0
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

		DECLARE @curdate DATETIME

		SET @curdate = GETDATE()

		WHILE EXISTS(SELECT TOP 1 * FROM dbo.ActFactMasterTable WHERE AFM_DATE = @curdate)
		BEGIN
			SET @curdate = GETDATE()
		END

		--	изменения от 22.06.2009:
		-- мастер
		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		SELECT
			ROW_NUMBER() OVER(ORDER BY CO_ID) AS 'AFM_ID',
			@curdate AS AFM_DATE,
			CL_ID,
			CL_PSEDO,
			CL_FULL_NAME,
			CL_SHORT_NAME,
			CO_ID,
			CO_NUM,
			CO_DATE,
			POS_NAME,
			PER_FAM,
			PER_NAME,
			PER_OTCH,
			ORG_ID,
			ORG_FULL_NAME,
			ORG_SHORT_NAME,
			ORG_INN,
			ORG_KPP,
			ISNULL(ORGC_ACCOUNT, ORG_ACCOUNT) AS ORG_ACCOUNT,
			BA_LORO AS ORG_LORO,
			BA_BIK AS ORG_BIK,
			ORG_DIR_FAM,
			ORG_DIR_NAME,
			ORG_DIR_OTCH,
			(ORG_DIR_FAM + ' ' + LEFT(ORG_DIR_NAME, 1) + '.' + LEFT(ORG_DIR_OTCH, 1) + '.') AS ORG_DIR_SHORT,
			BA_NAME,
			(SELECT DATENAME(MM, PR_DATE) FROM dbo.PeriodTable WHERE PR_ID=@periodid) AS PR_MONTH,
			--(SELECT PR_END_DATE FROM dbo.PeriodTable WHERE PR_ID=@periodid) AS PR_END_DATE
			ACT_DATE
			--(SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID=@periodid) AS PR_MONTH
		INTO
			#master
		FROM
			dbo.ActTable			A	LEFT JOIN
			dbo.ClientTable			B	ON	A.ACT_ID_CLIENT = B.CL_ID	LEFT JOIN
			dbo.ContractTable		C	ON	C.CO_ID_CLIENT	= B.CL_ID	LEFT JOIN
			--dbo.ContractDistrTable	D	ON	D.COD_ID_DISTR	= C.CO_ID	LEFT JOIN
			dbo.ClientPersonalTable	E	ON	E.PER_ID_CLIENT	= B.CL_ID	LEFT JOIN
			dbo.PositionTable		F	ON	E.PER_ID_POS	= F.POS_ID	LEFT JOIN
			dbo.OrganizationTable	G	ON	B.CL_ID_ORG		= G.ORG_ID	LEFT JOIN

			dbo.OrganizationCalc	J	ON  j.ORGC_ID		=	B.CL_ID_ORG_CALC LEFT JOIN
			dbo.BankTable			H	ON	ISNULL(J.ORGC_ID_BANK, G.ORG_ID_BANK)	= H.BA_ID


		-- деталь
		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		SELECT
			ROW_NUMBER() OVER(ORDER BY CO_ID) AS AFD_ID,
			AFM_ID AS AFD_ID_AFM,
			PR_ID,
			C.PR_DATE,
			DATENAME(MM, C.PR_DATE) AS PR_MONTH,
			C.PR_END_DATE,
			D.DIS_ID,
			DIS_NUM,
			SYS_NAME,
			SYS_ORDER,
			AD_PRICE,
			AD_TAX_PRICE,
			AD_TOTAL_PRICE,
			TX_PERCENT,
			TX_NAME,
			SO_ID,
			GD_NAME AS SO_BILL_STR,
			UN_NAME AS SO_INV_UNIT,
			ACT_ID_CLIENT,
			AD_PAYED_PRICE

		INTO #detail
		FROM
			dbo.ActDistrTable		A									LEFT JOIN
			dbo.ActTable			B	ON A.AD_ID_ACT	  = B.ACT_ID	LEFT JOIN
			dbo.PeriodTable			C	ON A.AD_ID_PERIOD = C.PR_ID		INNER JOIN
			dbo.DistrView			D WITH(NOEXPAND)	ON A.AD_ID_DISTR  = D.DIS_ID	LEFT JOIN
			dbo.DistrDocumentView	Z	ON Z.DIS_ID		  = D.DIS_ID	INNER JOIN
			dbo.SaleObjectTable		E	ON D.SYS_ID_SO	  = E.SO_ID		LEFT JOIN
			dbo.TaxTable			F	ON E.SO_ID_TAX	  = F.TX_ID		LEFT JOIN
			dbo.ContractDistrTable	H	ON H.COD_ID_DISTR = D.DIS_ID	LEFT JOIN
			#master				G	ON H.COD_ID_CONTRACT = G.CO_ID

		WHERE
			SYS_ID_SO = @soid AND DOC_PSEDO = 'ACT' AND DD_PRINT = 1
	--		AND PR_ID = @periodid
		--ORDER BY CL_PSEDO, CL_ID, CO_NUM, SYS_ORDER


		SELECT * FROM #master
		SELECT * FROM #detail
		--DROP TABLE #master
		--DROP TABLE #detail

		IF @preview <> 1
		BEGIN
			INSERT INTO dbo.ActFactMasterTable
				SELECT
					AFM_DATE, CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME,
					CO_ID, CO_NUM, CO_DATE, POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
					ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INN, ORG_KPP,
					ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_DIR_FAM, ORG_DIR_NAME,
					ORG_DIR_OTCH, ORG_DIR_SHORT,
					BA_NAME,
					PR_MONTH, PR_END_DATE
				FROM #master

			INSERT INTO dbo.ActFactDetailTable
				SELECT
					(SELECT AFM_ID FROM dbo.ActFactMasterTable
						WHERE AFM_DATE = @curdate AND CL_ID = ACT_ID_CLIENT),
					PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
					DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
					AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
					TX_PERCENT, TX_NAME, SO_ID, SO_BILL_STR, SO_INV_UNIT,
					AD_PAYED_PRICE
				FROM #detail
		END

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master
		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[ACT_FULL_SELECT] TO rl_act_r;
GO
