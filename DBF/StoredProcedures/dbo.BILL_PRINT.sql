USE [DBF]
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
ALTER PROCEDURE [dbo].[BILL_PRINT]
	@soid SMALLINT,
	@prid SMALLINT,
	@clid INT,
	@preview BIT,
	@courid VARCHAR(MAX),
	@billdate SMALLDATETIME = NULL,
	@group BIT = NULL,
	@togroup BIT = NULL
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

		IF @clid IS NOT NULL
			SELECT @group = BILL_GROUP
			FROM dbo.ClientFinancing
			WHERE ID_CLIENT = @clid

		DECLARE @curdate DATETIME

		SET @curdate = GETDATE()

		IF OBJECT_ID('tempdb..#cour') IS NOT NULL
			DROP TABLE #cour

		CREATE TABLE #cour
			(
				COUR_ID SMALLINT
			)

		IF @courid IS NULL
			INSERT INTO #cour (COUR_ID)
				SELECT COUR_ID
				FROM dbo.CourierTable
		ELSE
			INSERT INTO #cour
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@courid, ',')

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		CREATE TABLE #master
			(
				BFM_ID bigint IDENTITY(1,1) NOT NULL,
				BFM_DATE DATETIME NOT NULL,
				BFM_NUM VARCHAR(50) NULL,
				BFM_ID_PERIOD SMALLINT NOT NULL,
				BILL_DATE SMALLDATETIME NULL,
				CL_ID INT NOT NULL,
				CL_SHORT_NAME VARCHAR(500) NOT NULL,
				CL_CITY VARCHAR(100) NULL,
				CL_ADDRESS VARCHAR(250) NULL,
				ORG_ID SMALLINT NOT NULL,
				ORG_SHORT_NAME VARCHAR(100) NOT NULL,
				ORG_INDEX VARCHAR(50) NOT NULL,
				ORG_ADDRESS VARCHAR(250) NOT NULL,
				ORG_PHONE VARCHAR(100) NOT NULL,
				ORG_ACCOUNT VARCHAR(50) NOT NULL,
				ORG_LORO VARCHAR(50) NOT NULL,
				ORG_BIK VARCHAR(50) NOT NULL,
				ORG_INN VARCHAR(50) NOT NULL,
				ORG_KPP VARCHAR(50) NOT NULL,
				ORG_OKONH VARCHAR(50) NOT NULL,
				ORG_OKPO VARCHAR(50) NOT NULL,
				ORG_BUH_SHORT VARCHAR(150) NOT NULL,
				ORG_LOGO VARBINARY(MAX),
				BA_NAME VARCHAR(150) NULL,
				BA_CITY VARCHAR(150) NULL,
				CO_ID INT NULL,
				CO_NUM VARCHAR(500) NULL,
				CO_DATE SMALLDATETIME NULL,
				CK_HEADER	VARCHAR(150),
				ORG_BILL_SHORT	VARCHAR(128),
				ORG_BILL_POS	VARCHAR(128),
				ORG_BILL_NOTE	VARCHAR(128)
			)

		INSERT INTO #master
			(
				BFM_DATE, BFM_NUM, BFM_ID_PERIOD, BILL_DATE,
				CL_ID, CL_SHORT_NAME, CL_CITY, CL_ADDRESS, ORG_ID,
				ORG_SHORT_NAME, ORG_INDEX, ORG_ADDRESS, ORG_PHONE,
				ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
				ORG_BUH_SHORT, ORG_LOGO, BA_NAME, BA_CITY, CO_ID, CO_NUM, CO_DATE, CK_HEADER,
				ORG_BILL_SHORT, ORG_BILL_POS, ORG_BILL_NOTE
			)
		SELECT
			@curdate, NULL, @prid, @billdate,
			BL_ID_CLIENT, CL_SHORT_NAME, (d.CT_PREFIX + d.CT_NAME) AS CL_CITY,
			(ISNULL(d.ST_PREFIX + ' ', '') + d.ST_NAME + ISNULL(' ' + d.ST_SUFFIX, '') + ', ' + Z.CA_HOME) AS CL_ADDRESS,
			ORG_ID, ORG_SHORT_NAME,
			ORG_INDEX, --a.ST_PREFIX, a.ST_NAME, a.CT_PREFIX, a.CT_NAME, ORG_HOME,
			ISNULL((ORG_INDEX + ', ' + a.CT_PREFIX + a.CT_NAME + ', ' + a.ST_PREFIX + a.ST_NAME + ',' + ORG_HOME), '') AS ORG_ADDRESS,
			--ORG_S_INDEX, b.ST_PREFIX AS ST_S_PREFIX, b.ST_NAME AS ST_S_NAME,
			--b.CT_PREFIX AS CT_S_PREFIX, b.CT_NAME AS CT_S_NAME, ORG_S_HOME,
			ORG_PHONE,
			ISNULL(ORGC_ACCOUNT, ORG_ACCOUNT), ISNULL(BA_LORO, ''), ISNULL(BA_BIK, ''), ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
			--ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH,
			(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT,
			ORG_LOGO,
			--ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
			BA_NAME,
			c.CT_NAME AS BA_CITY, CO_ID, CO_NUM, CO_DATE, ISNULL(CK_HEADER, '��������'),
			ORG_BILL_SHORT, ORG_BILL_POS, ORG_BILL_MEMO
		FROM
			(
				SELECT a.BL_ID, a.BL_ID_CLIENT, BL_ID_PERIOD, BL_ID_ORG, BL_PRICE, BL_ID_PAYER
				FROM
					dbo.BillTable a INNER JOIN
					dbo.BillView b ON a.BL_ID = b.BL_ID
			) AS t LEFT OUTER JOIN
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
			dbo.ClientTable ON CL_ID = ISNULL(BL_ID_PAYER, BL_ID_CLIENT) --INNER JOIN
			INNER JOIN dbo.ClientFinancing ON CL_ID = ID_CLIENT
			/*#cour ON COUR_ID = CASE WHEN @COURID IS NULL THEN COUR_ID ELSE
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = BL_ID_CLIENT ORDER BY TO_MAIN DESC) END LEFT OUTER JOIN*/
				INNER JOIN
				(
					SELECT CL_ID AS CLIENT_ID
					FROM dbo.ClientTable
					WHERE @COURID IS NULL

					UNION ALL

					SELECT CL_ID
					FROM
						dbo.ClientCourView p
						INNER JOIN #cour q ON p.COUR_ID = q.COUR_ID
					WHERE @COURID IS NOT NULL
				) AS p ON p.CLIENT_ID = CL_ID
			LEFT OUTER JOIN dbo.ClientAddressTable ON CL_ID = CA_ID_CLIENT LEFT OUTER JOIN
			dbo.AddressView d ON CA_ID_STREET = ST_ID LEFT OUTER JOIN

			dbo.OrganizationTable ON ORG_ID = BL_ID_ORG LEFT OUTER JOIN
			dbo.OrganizationCalc ON ORGC_ID = CL_ID_ORG_CALC LEFT OUTER JOIN
			dbo.AddressView a ON a.ST_ID = ORG_ID_STREET LEFT OUTER JOIN
			dbo.AddressView b ON b.ST_ID = ORG_S_ID_STREET LEFT OUTER JOIN
			dbo.BankTable ON BA_ID = ISNULL(ORGC_ID_BANK, ORG_ID_BANK) LEFT OUTER JOIN

			dbo.ContractTable ON CO_ID_CLIENT = BL_ID_CLIENT LEFT OUTER JOIN
			dbo.ContractKind ON CK_ID = CO_ID_KIND LEFT OUTER JOIN
			dbo.CityTable c ON c.CT_ID = BA_ID_CITY	INNER JOIN
			-- 16.06.2009, ��� ���� ������
			dbo.ClientAddressView Z ON ClientAddressTable.CA_ID=Z.CA_ID	INNER JOIN
			dbo.FinancingAddressTypeTable Y ON Z.CA_ID_TYPE = Y.FAT_ID_ADDR_TYPE

		WHERE
			/*(
        		BL_PRICE - ISNULL(
            		(
        				SELECT SUM(ID_PRICE)
						FROM
    		        		dbo.IncomeDistrTable INNER JOIN
        					dbo.IncomeTable ON ID_ID_INCOME = IN_ID INNER JOIN
            				dbo.BillDistrTable ON BD_ID_BILL = BL_ID
            			WHERE ID_ID_DISTR = BD_ID_DISTR
            				AND ID_ID_PERIOD = PR_ID
							AND IN_ID_CLIENT = BL_ID_CLIENT
    				), 0)
			) > 0
			-- 3.06.09 ������� �.�. ������� ���� - �� ������, ���� � ������� �� �������� ������������ ��� ��� ������ ���������������
			AND*/ --16.06.2009
				--ISNULL(Z.CA_ID_TYPE, 3) = 3
				FAT_DOC='BILL'
			AND (BILL_MASS_PRINT = 1 OR @clid IS NOT NULL)
			--AND PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid)
			AND PR_ID = @prid
			AND BL_ID_CLIENT = ISNULL(@clid, BL_ID_CLIENT)
			AND ISNULL(CO_ACTIVE, 1) = 1

		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		CREATE TABLE #detail
			(
				BFD_ID_BFM BIGINT NULL,
				BL_ID_CLIENT INT NOT NULL,
				CO_NUM VARCHAR(500) NULL,
				--CO_DATE SMALLDATETIME NULL,
				BILL_STR VARCHAR(150) NOT NULL,
				TX_PERCENT DECIMAL(8, 4) NOT NULL,
				TX_NAME VARCHAR(50) NOT NULL,
				SYS_NAME VARCHAR(250) NOT NULL,
				SYS_ORDER SMALLINT NULL,
				DIS_ID INT NOT NULL,
				DIS_NUM VARCHAR(20) NULL,
				TO_NUM	INT,
				TO_NAME	NVARCHAR(250),
				SYS_ID INT,
				PR_ID SMALLINT NOT NULL,
				PR_MONTH VARCHAR(50) NOT NULL,
				PR_DATE SMALLDATETIME NOT NULL,
				BD_UNPAY MONEY NOT NULL,
				BD_TAX_UNPAY MONEY NOT NULL,
				BD_TOTAL_UNPAY MONEY NOT NULL
			)

		INSERT INTO #detail
			(
				BFD_ID_BFM, BL_ID_CLIENT, CO_NUM, BILL_STR, TX_PERCENT, TX_NAME, SYS_NAME, SYS_ORDER,
				DIS_ID, DIS_NUM, TO_NUM, TO_NAME, SYS_ID, PR_ID, PR_MONTH, PR_DATE, BD_UNPAY, BD_TAX_UNPAY, BD_TOTAL_UNPAY
			)
		SELECT
			(
				SELECT TOP 1 BFM_ID
				FROM
					#master a LEFT OUTER JOIN
					dbo.ContractTable b ON a.CO_ID = b.CO_ID LEFT OUTER JOIN
					dbo.ContractDistrTable c ON c.COD_ID_CONTRACT = b.CO_ID
				WHERE BFM_DATE = @curdate
					AND CL_ID = BL_ID_CLIENT
					AND BD_ID_DISTR = ISNULL(COD_ID_DISTR, BD_ID_DISTR)
				ORDER BY BFM_ID
			),
			BL_ID_CLIENT,
			(
				SELECT TOP 1 CO_NUM
				FROM
					dbo.ContractDistrTable INNER JOIN
					dbo.ContractTable ON CO_ID_CLIENT = BL_ID_CLIENT AND COD_ID_CONTRACT = CO_ID 
				WHERE COD_ID_DISTR = a.DIS_ID AND CO_ACTIVE = 1
				ORDER BY CO_DATE DESC, CO_ACTIVE DESC
			),
			--, CO_DATE,
			GD_NAME, TX_PERCENT, TX_NAME,
			CASE ISNULL(DF_NAME, '') WHEN '' THEN ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME ELSE DF_NAME END,
			SYS_ORDER,

			a.DIS_ID, DIS_NUM,
			(
				SELECT TOP 1 TO_NUM
				FROM
					dbo.TODistrTable INNER JOIN
					dbo.TOTable ON TO_ID = TD_ID_TO
				WHERE TD_ID_DISTR = a.DIS_ID
			),
			(
				SELECT TOP 1 TO_NAME
				FROM
					dbo.TODistrTable INNER JOIN
					dbo.TOTable ON TO_ID = TD_ID_TO
				WHERE TD_ID_DISTR = a.DIS_ID
			),
			a.SYS_ID, PR_ID, DATENAME(MM, PR_DATE) AS PR_MONTH, PR_DATE,
			--BD_PRICE, BD_TAX_PRICE, BD_TOTAL_PRICE,
			CAST(ROUND((
				BD_TOTAL_PRICE - CONVERT(TINYINT, z.DF_DEBT) *
					ISNULL
						(
							(
								SELECT SUM(ID_PRICE)
								FROM
									/*
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									*/
									dbo.IncomeIXView WITH(NOEXPAND)
								WHERE ID_ID_PERIOD = BL_ID_PERIOD
									AND ID_ID_DISTR = BD_ID_DISTR
									AND BL_ID_CLIENT = IN_ID_CLIENT
							), 0)
			)/(1 + TX_PERCENT/100), 2) AS MONEY) AS BD_UNPAY,
			CAST(
			CAST(ROUND((
				BD_TOTAL_PRICE - CONVERT(TINYINT, z.DF_DEBT) *
					ISNULL
						(
							(
								SELECT SUM(ID_PRICE)
								FROM
									/*
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									*/
									dbo.IncomeIXView WITH(NOEXPAND)
								WHERE ID_ID_PERIOD = BL_ID_PERIOD
									AND ID_ID_DISTR = BD_ID_DISTR
									AND BL_ID_CLIENT = IN_ID_CLIENT
							), 0)
			), 2) AS MONEY) -
			CAST(ROUND((
				BD_TOTAL_PRICE - CONVERT(TINYINT, z.DF_DEBT) *
					ISNULL
						(
							(
								SELECT SUM(ID_PRICE)
								FROM
									/*
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									*/
									dbo.IncomeIXView WITH(NOEXPAND)
								WHERE ID_ID_PERIOD = BL_ID_PERIOD
									AND ID_ID_DISTR = BD_ID_DISTR
									AND BL_ID_CLIENT = IN_ID_CLIENT
							), 0)
			)/(1 + TX_PERCENT/100), 2) AS MONEY) AS MONEY) AS BD_TAX_UNPAY,

			CAST(ROUND((
				BD_TOTAL_PRICE - CONVERT(TINYINT, z.DF_DEBT) *
					ISNULL
						(
							(
								SELECT SUM(ID_PRICE)
								FROM
									/*
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									*/
									dbo.IncomeIXView WITH(NOEXPAND)
								WHERE ID_ID_PERIOD = BL_ID_PERIOD
									AND ID_ID_DISTR = BD_ID_DISTR
									AND BL_ID_CLIENT = IN_ID_CLIENT
							), 0)
			), 2) AS MONEY) AS BD_TOTAL_UNPAY
		FROM
			(
				SELECT BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, BL_ID_ORG,
					CASE BL_ID_PERIOD
						WHEN @prid THEN
							(
								BD_TOTAL_PRICE + CONVERT(TINYINT, p.DF_DEBT) *
									ISNULL(
											(
												SELECT SUM(BD_REST)
												FROM
													dbo.BillRestView c INNER JOIN
													dbo.PeriodTable ON PR_ID = BL_ID_PERIOD
												WHERE PR_DATE <
														(SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid)
													AND a.BD_ID_DISTR = c.BD_ID_DISTR
													AND b.BL_ID_CLIENT = c.BL_ID_CLIENT
											), 0
							)
							)
						ELSE BD_TOTAL_PRICE
					END AS BD_TOTAL_PRICE,
					BD_DATE
				FROM
					dbo.BillDistrTable a INNER JOIN
					dbo.BillTable b ON BL_ID = BD_ID_BILL INNER JOIN
					dbo.DistrFinancingTable p ON p.DF_ID_DISTR = a.BD_ID_DISTR
			) AS t INNER JOIN
			dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
			dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = BD_ID_DISTR INNER JOIN
			dbo.DistrFinancingTable z ON z.DF_ID_DISTR = DIS_ID INNER JOIN
			dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
			dbo.SaleObjectTable ON SYS_ID_SO = SO_ID INNER JOIN
			dbo.TaxTable ON TX_ID = SO_ID_TAX /*INNER JOIN
			#cour ON COUR_ID =
				(SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = BL_ID_CLIENT ORDER BY TO_ID_COUR) */--LEFT OUTER JOIN
			--dbo.ContractDistrTable ON COD_ID_DISTR = a.DIS_ID LEFT OUTER JOIN
			--dbo.ContractTable ON CO_ID_CLIENT = BL_ID_CLIENT AND COD_ID_CONTRACT = CO_ID 
		WHERE 
			(
				BD_TOTAL_PRICE - CONVERT(TINYINT, z.DF_DEBT) *
					ISNULL
						(
							(
								SELECT SUM(ID_PRICE)
								FROM
									/*
									dbo.IncomeDistrTable INNER JOIN
									dbo.IncomeTable ON IN_ID = ID_ID_INCOME
									*/
									dbo.IncomeIXView WITH(NOEXPAND)
								WHERE ID_ID_PERIOD = BL_ID_PERIOD
									AND ID_ID_DISTR = BD_ID_DISTR
									AND BL_ID_CLIENT = IN_ID_CLIENT
							), 0)
			) > 0
			AND SYS_ID_SO = @soid
			AND DOC_PSEDO = 'BILL'
			AND DD_PRINT = 1
			-- 3.06.09 ������� �.�. ������� ���� - �� ������, ���� � ������� �� �������� ������������ ��� ��� ������ ���������������
			--AND ISNULL(CO_ACTIVE, 1) = 1
			--AND --16.06.2009
				--ISNULL(Z.CA_ID_TYPE, 3) = 3
				--FAT_DOC='bill-pay'

			AND
				(
					PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid) AND DF_DEBT = 1
					OR
					PR_DATE = (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid) AND DF_DEBT = 0
				)
			AND BL_ID_CLIENT = ISNULL(@clid, BL_ID_CLIENT)
			AND EXISTS
					(
						SELECT *
						FROM #master
						WHERE BFM_DATE = @curdate AND CL_ID = BL_ID_CLIENT
					)
		ORDER BY SYS_ORDER, DIS_NUM, PR_DATE

		DELETE FROM #master
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #detail
				WHERE BFM_ID = BFD_ID_BFM
			)


		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				CL_ID INT,
				CL_SHORT_NAME VARCHAR(200),
				CO_ID INT,
				CO_NUM VARCHAR(500),
				ORG_ID SMALLINT,
				NUM INT NULL
			)

		DECLARE @prdate SMALLDATETIME

		DECLARE @min INT

		DECLARE @date SMALLDATETIME


		DECLARE @orgid SMALLINT

		DECLARE BILLS CURSOR LOCAL FOR
			SELECT DISTINCT ORG_ID FROM #master

		OPEN BILLS

		FETCH NEXT FROM BILLS INTO @orgid

		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM #tmp

			INSERT INTO #tmp
				SELECT DISTINCT CL_ID, CL_SHORT_NAME, CO_ID, CO_NUM, ORG_ID, NULL
				FROM #master
				WHERE BFM_NUM IS NULL
					AND BFM_DATE = @curdate
					AND EXISTS
						(
							SELECT *
							FROM #detail
							WHERE BFM_ID = BFD_ID_BFM
						)
					AND ORG_ID = @orgid
				ORDER BY CL_SHORT_NAME, CL_ID, CO_ID, CO_NUM



			SELECT @prdate = PR_DATE
			FROM dbo.PeriodTable
			WHERE PR_ID = @prid



			SET @date = @prdate

			SELECT @min = MAX(CONVERT(INT, RIGHT(BFM_NUM, LEN(BFM_NUM) - CHARINDEX('-', BFM_NUM))))
			FROM dbo.BillFactMasterTable
			WHERE BFM_ID_PERIOD = @prid AND ORG_ID = @orgid

			SET @min = ISNULL(@min, 1)

			UPDATE #master
			SET BFM_NUM =
					(
						SELECT TOP 1 BFM_NUM
						FROM dbo.BillFactMasterTable
						WHERE BFM_ID_PERIOD = @prid
							AND BillFactMasterTable.CL_ID = #master.CL_ID
							AND #master.CO_NUM = BillFactMasterTable.CO_NUM
							AND #master.ORG_ID = BillFactMasterTable.ORG_ID
							AND SO_ID = @soid
							AND #master.ORG_ID = @orgid
						ORDER BY BFM_DATE DESC
					),
				BILL_DATE =
					--ISNULL((
					(
						SELECT TOP 1 BILL_DATE
						FROM dbo.BillFactMasterTable
						WHERE BFM_ID_PERIOD = @prid
							AND dbo.BillFactMasterTable.CL_ID = #master.CL_ID
							AND #master.CO_NUM = BillFactMasterTable.CO_NUM
							AND dbo.BillFactMasterTable.ORG_ID = #master.ORG_ID
						ORDER BY BFM_DATE DESC
					)
					--), @billdate)
			WHERE #master.ORG_ID = @orgid

			UPDATE #master
			SET BILL_DATE = @billdate
			WHERE BILL_DATE IS NULL
				AND ORG_ID = @orgid

			IF (SELECT COUNT(*) FROM #tmp) = 1
			BEGIN
				UPDATE #master
				SET BFM_NUM = '��' + CONVERT(VARCHAR, DATEPART(m, @prdate)) + '-' + CONVERT(VARCHAR, @min + 1)
				WHERE BFM_DATE = @curdate AND BFM_NUM IS NULL AND ORG_ID = @orgid
			END
			ELSE
			BEGIN
				DECLARE @i INT
				SET @i = @min - 1

				UPDATE #tmp
					SET NUM = @i,
					@i = @i + 1
				FROM
					(
						SELECT DISTINCT CL_ID, CO_ID, CO_NUM, ORG_ID
						FROM #tmp a
						WHERE NUM IS NULL AND ORG_ID = @orgid
					) AS ds
				WHERE NUM IS NULL
					AND
						(
							ds.CL_ID <> #tmp.CL_ID	OR
							ds.CO_ID <> #tmp.CO_ID	OR
							ds.CO_NUM <> #tmp.CO_NUM OR
							ds.ORG_ID <> #tmp.ORG_ID
						)

				UPDATE #master
				SET #master.BFM_NUM = '��' +
									(CONVERT(VARCHAR, DATEPART(m, @prdate)) +
									'-' + CONVERT(VARCHAR, a.NUM))
				FROM #tmp a
				WHERE #master.BFM_NUM IS NULL
					AND a.CL_ID = #master.CL_ID
					AND ISNULL(a.CO_ID, 0) = ISNULL(#master.CO_ID, 0)
					AND ISNULL(a.CO_NUM, 0) = ISNULL(#master.CO_NUM, 0)
					AND BFM_DATE = @curdate
					AND #master.ORG_ID = a.ORG_ID
					AND a.ORG_ID = @orgid
			END

			FETCH NEXT FROM BILLS INTO @orgid
		END

		CLOSE BILLS
		DEALLOCATE BILLS



		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		IF (@preview <> 1) AND (@clid IS NOT NULL)
		BEGIN
			DELETE
			FROM dbo.BillFactDetailTable
			WHERE BFD_ID_BFM IN
				(
					SELECT BFM_ID
					FROM dbo.BillFactMasterTable
					WHERE BFM_ID_PERIOD = @prid
						AND CL_ID = @clid
			)

			DELETE
			FROM dbo.BillFactMasterTable
			WHERE BFM_ID_PERIOD = @prid
				AND CL_ID = @clid
		END



		IF @preview <> 1
		BEGIN
			INSERT INTO dbo.BillFactMasterTable
				(
					BFM_DATE, BFM_NUM, BFM_ID_PERIOD, BILL_DATE, CL_ID, CL_SHORT_NAME, CL_CITY, CL_ADDRESS, ORG_ID,
					ORG_SHORT_NAME, ORG_INDEX, ORG_ADDRESS, ORG_PHONE,
					ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
					ORG_BUH_SHORT, BA_NAME, BA_CITY, CO_ID, CO_NUM, CO_DATE, SO_ID, CK_HEADER,
					ORG_BILL_SHORT, ORG_BILL_POS, ORG_BILL_NOTE
				)
			SELECT
				BFM_DATE, BFM_NUM, BFM_ID_PERIOD, BILL_DATE, CL_ID, CL_SHORT_NAME, CL_CITY, CL_ADDRESS, ORG_ID,
				ORG_SHORT_NAME, ORG_INDEX, ORG_ADDRESS, ORG_PHONE,
				ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
				ORG_BUH_SHORT, BA_NAME, BA_CITY, CO_ID, CO_NUM, CO_DATE, @soid, CK_HEADER,
				ORG_BILL_SHORT, ORG_BILL_POS, ORG_BILL_NOTE
			FROM #master
			WHERE EXISTS
				(
					SELECT * FROM #detail WHERE BFM_ID = BFD_ID_BFM
				)

			INSERT INTO dbo.BillFactDetailTable
				(
					BFD_ID_BFM, BILL_STR, TX_PERCENT, TX_NAME, SYS_NAME, SYS_ORDER,
					DIS_ID, DIS_NUM, PR_ID, PR_MONTH, PR_DATE, BD_UNPAY, BD_TAX_UNPAY, BD_TOTAL_UNPAY
				)
				SELECT
					(
						SELECT TOP 1 BFM_ID
						FROM dbo.BillFactMasterTable b
						WHERE BFM_DATE = @curdate AND CL_ID = BL_ID_CLIENT AND a.CO_NUM = b.CO_NUM
						ORDER BY BFM_ID
					), BILL_STR, TX_PERCENT, TX_NAME, SYS_NAME, SYS_ORDER,
					DIS_ID, DIS_NUM, PR_ID, PR_MONTH, PR_DATE, BD_UNPAY, BD_TAX_UNPAY, BD_TOTAL_UNPAY
				FROM #detail a
				WHERE EXISTS
					(
						SELECT *
						FROM dbo.BillFactMasterTable c
						WHERE BFM_DATE = @curdate AND CL_ID = BL_ID_CLIENT AND a.CO_NUM = c.CO_NUM
					)
		END

		SELECT *,
			(
				SELECT TOP 1 COUR_NAME
				FROM dbo.TOTable INNER JOIN
					dbo.CourierTable ON COUR_ID = TO_ID_COUR
				WHERE TO_ID_CLIENT = CL_ID
				ORDER BY TO_MAIN DESC
			) AS COUR_NAME,
			CASE @togroup WHEN 1 THEN 1 ELSE 0 END AS TO_GROUP
		FROM #master
		WHERE EXISTS
				(
					SELECT * FROM #detail WHERE BFM_ID = BFD_ID_BFM
				)
		ORDER BY COUR_NAME, CL_SHORT_NAME, CL_ID, CO_NUM, CO_ID
		--ORDER BY BFM_NUM

		IF @togroup = 1
			SELECT
					BFD_ID_BFM,
					BL_ID_CLIENT,
					CO_NUM,
					BILL_STR,
					TX_PERCENT,
					TX_NAME,
					SYS_NAME,
					SYS_ORDER,
					DIS_ID,
					DIS_NUM,
					TO_NUM,
					TO_NAME,
					PR_ID,
					PR_MONTH,
					PR_DATE,
					BD_UNPAY,
					BD_TAX_UNPAY,
					BD_TOTAL_UNPAY
				FROM #detail
				ORDER BY TO_NUM, TO_NAME, SYS_ORDER, DIS_NUM, PR_DATE
		ELSE
		BEGIN
			IF @GROUP = 1
				SELECT
					BFD_ID_BFM,
					BL_ID_CLIENT,
					CO_NUM,
					BILL_STR,
					TX_PERCENT,
					TX_NAME,
					NULL AS TO_NUM,
					NULL AS TO_NAME,
					SYS_NAME,
					SYS_ORDER,
					SYS_ID AS DIS_ID,
					CONVERT(VARCHAR(20), COUNT(*)) + ' ��' AS DIS_NUM,
					PR_ID,
					PR_MONTH,
					PR_DATE,
					SUM(BD_UNPAY) AS BD_UNPAY,
					SUM(BD_TAX_UNPAY) AS BD_TAX_UNPAY,
					SUM(BD_TOTAL_UNPAY) AS BD_TOTAL_UNPAY
				FROM #detail
				GROUP BY BFD_ID_BFM, BL_ID_CLIENT, CO_NUM, BILL_STR, TX_PERCENT, TX_NAME, SYS_NAME, SYS_ORDER, SYS_ID, PR_ID, PR_MONTH, PR_DATE
				ORDER BY SYS_ORDER, PR_DATE
			ELSE IF @GROUP = 0
				SELECT
					BFD_ID_BFM,
					BL_ID_CLIENT,
					CO_NUM,
					BILL_STR,
					TX_PERCENT,
					TX_NAME,
					NULL AS TO_NUM,
					NULL AS TO_NAME,
					SYS_NAME,
					SYS_ORDER,
					DIS_ID,
					DIS_NUM,
					PR_ID,
					PR_MONTH,
					PR_DATE,
					BD_UNPAY,
					BD_TAX_UNPAY,
					BD_TOTAL_UNPAY
				FROM #detail
				ORDER BY SYS_ORDER, DIS_NUM, PR_DATE
			ELSE IF @GROUP IS NULL
				SELECT
					BFD_ID_BFM,
					BL_ID_CLIENT,
					CO_NUM,
					BILL_STR,
					TX_PERCENT,
					TX_NAME,
					NULL AS TO_NUM,
					NULL AS TO_NAME,
					SYS_NAME,
					SYS_ORDER,
					SYS_ID AS DIS_ID,
					CONVERT(VARCHAR(20), COUNT(*)) + ' ��' AS DIS_NUM,
					0 AS DIS_NUM_INT,
					PR_ID,
					PR_MONTH,
					PR_DATE,
					SUM(BD_UNPAY) AS BD_UNPAY,
					SUM(BD_TAX_UNPAY) AS BD_TAX_UNPAY,
					SUM(BD_TOTAL_UNPAY) AS BD_TOTAL_UNPAY
				FROM
					#detail
					INNER JOIN dbo.ClientFinancing ON ID_CLIENT = BL_ID_CLIENT
				WHERE BILL_GROUP = 1
				GROUP BY BFD_ID_BFM, BL_ID_CLIENT, CO_NUM, BILL_STR, TX_PERCENT, TX_NAME, SYS_NAME, SYS_ORDER, SYS_ID, PR_ID, PR_MONTH, PR_DATE

				UNION ALL

				SELECT
					BFD_ID_BFM,
					BL_ID_CLIENT,
					CO_NUM,
					BILL_STR,
					TX_PERCENT,
					TX_NAME,
					NULL AS TO_NUM,
					NULL AS TO_NAME,
					SYS_NAME,
					SYS_ORDER,
					DIS_ID,
					CONVERT(VARCHAR(20), DIS_NUM) AS DIS_NUM,
					DIS_NUM AS DIS_NUM_INT,
					PR_ID,
					PR_MONTH,
					PR_DATE,
					BD_UNPAY,
					BD_TAX_UNPAY,
					BD_TOTAL_UNPAY
				FROM
					#detail
					INNER JOIN dbo.ClientFinancing ON ID_CLIENT = BL_ID_CLIENT
				WHERE BILL_GROUP = 0
				ORDER BY SYS_ORDER, DIS_NUM_INT, PR_DATE
		END


		IF OBJECT_ID('tempdb..#cour') IS NOT NULL
			DROP TABLE #cour

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
GRANT EXECUTE ON [dbo].[BILL_PRINT] TO rl_bill_p;
GO
