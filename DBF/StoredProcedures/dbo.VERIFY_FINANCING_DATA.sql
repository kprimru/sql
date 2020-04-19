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

CREATE PROCEDURE [dbo].[VERIFY_FINANCING_DATA]
	@clientid INT,
	@report BIT,
	@prlist VARCHAR(MAX),
	@billinc BIT,
	@billact BIT,
	@incact BIT
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

		IF OBJECT_ID('tempdb..#pr') IS NOT NULL
			DROP TABLE #pr

		CREATE TABLE #pr
			(
				PPR_ID SMALLINT
			)

		IF @prlist IS NOT NULL
			INSERT INTO #pr
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@prlist, ',')
		ELSE
			INSERT INTO #pr 
				SELECT PR_ID FROM dbo.PeriodTable

		IF OBJECT_ID('tempdb..#disperiod') IS NOT NULL
			DROP TABLE #disperiod

		CREATE TABLE #disperiod
			(
				TCL_ID INT,
				TDIS_ID INT,
				TPR_ID SMALLINT
			)

		IF @clientid IS NULL
		BEGIN
			INSERT INTO #disperiod(TCL_ID, TDIS_ID, TPR_ID)
				SELECT DISTINCT ACT_ID_CLIENT, AD_ID_DISTR, AD_ID_PERIOD
				FROM 
					dbo.ActTable INNER JOIN
					dbo.ActDistrTable ON AD_ID_ACT = ACT_ID INNER JOIN
					#pr ON PPR_ID = AD_ID_PERIOD
				UNION
				SELECT DISTINCT BL_ID_CLIENT, BD_ID_DISTR, BL_ID_PERIOD
				FROM 
					dbo.BillTable INNER JOIN
					dbo.BillDistrTable ON BD_ID_BILL = BL_ID INNER JOIN
					#pr ON PPR_ID = BL_ID_PERIOD
				UNION
				SELECT DISTINCT IN_ID_CLIENT, ID_ID_DISTR, ID_ID_PERIOD
				FROM 
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID INNER JOIN
					#pr ON PPR_ID = ID_ID_PERIOD
				UNION
				SELECT DISTINCT CSG_ID_CLIENT, CSD_ID_DISTR, CSD_ID_PERIOD
				FROM 
					dbo.ConsignmentTable INNER JOIN
					dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID INNER JOIN
					#pr ON PPR_ID = CSD_ID_PERIOD
		END
		ELSE
		BEGIN
			INSERT INTO #disperiod(TCL_ID, TDIS_ID, TPR_ID)
				SELECT DISTINCT ACT_ID_CLIENT, AD_ID_DISTR, AD_ID_PERIOD
				FROM 
					dbo.ActTable INNER JOIN
					dbo.ActDistrTable ON AD_ID_ACT = ACT_ID INNER JOIN
					#pr ON PPR_ID = AD_ID_PERIOD
				WHERE ACT_ID_CLIENT = @clientid
				UNION
				SELECT DISTINCT BL_ID_CLIENT, BD_ID_DISTR, BL_ID_PERIOD
				FROM 
					dbo.BillTable INNER JOIN
					dbo.BillDistrTable ON BD_ID_BILL = BL_ID INNER JOIN
					#pr ON PPR_ID = BL_ID_PERIOD
				WHERE BL_ID_CLIENT = @clientid
				UNION
				SELECT DISTINCT IN_ID_CLIENT, ID_ID_DISTR, ID_ID_PERIOD
				FROM 
					dbo.IncomeTable INNER JOIN
					dbo.IncomeDistrTable ON ID_ID_INCOME = IN_ID INNER JOIN
					#pr ON PPR_ID = ID_ID_PERIOD
				WHERE IN_ID_CLIENT = @clientid
				UNION
				SELECT DISTINCT CSG_ID_CLIENT, CSD_ID_DISTR, CSD_ID_PERIOD
				FROM 
					dbo.ConsignmentTable INNER JOIN
					dbo.ConsignmentDetailTable ON CSD_ID_CONS = CSG_ID INNER JOIN
					#pr ON PPR_ID = CSD_ID_PERIOD
				WHERE CSG_ID_CLIENT = @clientid
		END

		IF @report = 1
			DELETE
			FROM #disperiod
			WHERE TDIS_ID IN
				(
					SELECT DIS_ID
					FROM dbo.ClientDistrView
					WHERE DSS_REPORT <> 1
				)

		IF OBJECT_ID('tempdb..#verify') IS NOT NULL
			DROP TABLE #verify

		CREATE TABLE #verify
			(
				VCL_ID INT,
				VDIS_ID INT,
				VPR_ID SMALLINT,
				VB_PRICE MONEY,
				VI_PRICE MONEY,
				VA_PRICE MONEY
			)

		INSERT INTO #verify(VCL_ID, VDIS_ID, VPR_ID, VB_PRICE, VI_PRICE, VA_PRICE)
			SELECT 
				TCL_ID, TDIS_ID, TPR_ID, 
				ISNULL((
					SELECT SUM(BD_TOTAL_PRICE)
					FROM 
						dbo.BillDistrTable INNER JOIN
						dbo.BillTable ON BL_ID = BD_ID_BILL
					WHERE BL_ID_CLIENT = TCL_ID 
						AND BD_ID_DISTR = TDIS_ID 
						AND BL_ID_PERIOD = TPR_ID
				), 0) AS BILL_PRICE,
				ISNULL((
					SELECT SUM(ID_PRICE)
					FROM 
						dbo.IncomeDistrTable INNER JOIN
						dbo.IncomeTable ON IN_ID = ID_ID_INCOME
					WHERE IN_ID_CLIENT = TCL_ID 
						AND ID_ID_DISTR = TDIS_ID 
						AND ID_ID_PERIOD = TPR_ID
				), 0) AS INCOME_PRICE,
				ISNULL((
					SELECT SUM(AD_TOTAL_PRICE)
					FROM 
						dbo.ActDistrTable INNER JOIN
						dbo.ActTable ON ACT_ID = AD_ID_ACT
					WHERE ACT_ID_CLIENT = TCL_ID 
						AND AD_ID_DISTR = TDIS_ID 
						AND AD_ID_PERIOD = TPR_ID
				), 0) + 
				ISNULL((
					SELECT SUM(CSD_TOTAL_PRICE)
					FROM 
						dbo.ConsignmentDetailTable INNER JOIN
						dbo.ConsignmentTable ON CSG_ID = CSD_ID_CONS
					WHERE CSG_ID_CLIENT = TCL_ID 
						AND CSD_ID_DISTR = TDIS_ID 
						AND CSD_ID_PERIOD = TPR_ID
				), 0)  AS ACT_PRICE
			FROM 
				#disperiod

		DECLARE @sql VARCHAR(MAX)

		SET @sql = ''

		IF @billinc = 1 
		BEGIN
			SET @sql = @sql + 'UNION
			SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE, VB_PRICE, VI_PRICE, VA_PRICE, ''Несоответствие данных'' AS VER_TEXT
			FROM 
				#verify INNER JOIN	
				dbo.ClientTable ON CL_ID = VCL_ID INNER JOIN
				dbo.DistrView WITH(NOEXPAND) ON DIS_ID = VDIS_ID INNER JOIN
				dbo.PeriodTable ON PR_ID = VPR_ID
			WHERE VI_PRICE <> VB_PRICE '
		END
		
		IF @billact = 1
		BEGIN
			SET @sql = @sql + 'UNION
			SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE, VB_PRICE, VI_PRICE, VA_PRICE, ''Несоответствие данных'' AS VER_TEXT
			FROM 
				#verify INNER JOIN	
				dbo.ClientTable ON CL_ID = VCL_ID INNER JOIN
				dbo.DistrView WITH(NOEXPAND) ON DIS_ID = VDIS_ID INNER JOIN
				dbo.PeriodTable ON PR_ID = VPR_ID
			WHERE VB_PRICE <> VA_PRICE '
		END
		
		IF @incact = 1
		BEGIN
			SET @sql = @sql + 'UNION
			SELECT CL_ID, CL_PSEDO, DIS_STR, PR_DATE, VB_PRICE, VI_PRICE, VA_PRICE, ''Несоответствие данных'' AS VER_TEXT
			FROM 
				#verify INNER JOIN	
				dbo.ClientTable ON CL_ID = VCL_ID INNER JOIN
				dbo.DistrView WITH(NOEXPAND) ON DIS_ID = VDIS_ID INNER JOIN
				dbo.PeriodTable ON PR_ID = VPR_ID
			WHERE VA_PRICE <> VI_PRICE '
		END

		SET @sql = RIGHT(@sql, LEN(@sql) - 6)
		SET @sql = @sql + '
		ORDER BY CL_PSEDO, DIS_STR, PR_DATE'
			
		--SELECT @sql
		EXEC (@sql)

		IF OBJECT_ID('tempdb..#verify') IS NOT NULL
			DROP TABLE #verify

		IF OBJECT_ID('tempdb..#disperiod') IS NOT NULL
			DROP TABLE #disperiod

		IF OBJECT_ID('tempdb..#pr') IS NOT NULL
			DROP TABLE #pr		
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
