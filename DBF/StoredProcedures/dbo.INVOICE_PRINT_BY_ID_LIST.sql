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
������:			21.07.2009
��������:		��������� ����������� �� ������-������
*/
ALTER PROCEDURE [dbo].[INVOICE_PRINT_BY_ID_LIST]
	@invid VARCHAR(MAX),
	@preview BIT = 1,
	@group BIT = 0,
	@print_master Bit  = 1,
	@print_detail Bit = 1
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

		IF OBJECT_ID('tempdb..#inv') IS NOT NULL
			DROP TABLE #inv


		CREATE TABLE #inv
			(
				INV_ID INT PRIMARY KEY CLUSTERED
			)

		INSERT INTO #inv
		SELECT DISTINCT *
		FROM dbo.GET_TABLE_FROM_LIST(@invid, ',');

		INSERT INTO dbo.FinancingProtocol(ID_CLIENT, ID_DOCUMENT, TP, OPER, TXT)
		SELECT INS_ID_CLIENT, INS_ID, 'INVOICE', '������ �/�', '�' + CONVERT(VARCHAR(20), INS_NUM) + '/' + CONVERT(VARCHAR(20), INS_NUM_YEAR)
		FROM
			dbo.InvoiceSaleTable
			INNER JOIN #inv ON INS_ID = INV_ID

		DECLARE @date DATETIME
		SET @date = GETDATE()

		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		CREATE TABLE #master
			(
				IFM_ID BIGINT IDENTITY(1, 1),
				IFM_DATE DATETIME,
				INS_ID INT,
				INS_DATE SMALLDATETIME,
				INS_NUM INT,
				INS_NUM_YEAR VARCHAR(5),
				INS_DOC_STRING VARCHAR(500),
				ORG_ID SMALLINT,
				ORG_PSEDO VARCHAR(50),
				ORG_FULL_NAME VARCHAR(500),
				ORG_SHORT_NAME VARCHAR(50),
				ORG_ADDRESS VARCHAR(500),
				ORG_INN VARCHAR(50),
				ORG_KPP VARCHAR(50),
				ORG_DIR_SHORT VARCHAR(50),
				ORG_BUH_SHORT VARCHAR(50),
				CL_ID INT,
				CL_PSEDO VARCHAR(50),
				CL_FULL_NAME VARCHAR(500),
				CL_SHORT_NAME VARCHAR(150),
				CL_KPP VARCHAR(50),
				CL_INN VARCHAR(50),
				INS_CLIENT_ADDR VARCHAR(500),
				INS_CONSIG_ADDR VARCHAR(500),
				INS_CONSIG_NAME VARCHAR(500),
				INS_ID_TYPE SMALLINT,
				COUR_NAME VARCHAR(100),
				INS_IDENT NVARCHAR(128),
				ACT_DATE    SmallDateTime,
				ACT_NUM     VarChar(100)
			)

		INSERT INTO #master (
						IFM_DATE,
						INS_ID,
						INS_DATE,
						INS_NUM, INS_NUM_YEAR, INS_DOC_STRING,
						ORG_ID, ORG_PSEDO, ORG_FULL_NAME,
						ORG_SHORT_NAME, ORG_ADDRESS, ORG_INN, ORG_KPP,
						ORG_DIR_SHORT, ORG_BUH_SHORT,
						CL_ID, CL_PSEDO, CL_FULL_NAME,
						CL_SHORT_NAME, CL_KPP, CL_INN, INS_CLIENT_ADDR,
						INS_CONSIG_ADDR, INS_CONSIG_NAME, INS_ID_TYPE, COUR_NAME, INS_IDENT, ACT_DATE, ACT_NUM
					)
			SELECT
					@date,
					INS_ID,
					INS_DATE,
					INS_NUM, INS_NUM_YEAR, INS_DOC_STRING,
					ORG_ID, ORG_PSEDO, ORG_FULL_NAME,
					ORG_SHORT_NAME, ORG_ADDRESS, ORG_INN, ORG_KPP,
					ORG_DIR_SHORT, ORG_BUH_SHORT,
					CL_ID, CL_PSEDO, INS_CLIENT_NAME, --CL_FULL_NAME,
					CL_SHORT_NAME, CASE WHEN INS_CLIENT_KPP <> '' THEN INS_CLIENT_KPP ELSE CL_KPP END AS CL_KPP,
					CASE WHEN INS_CLIENT_INN <> '' THEN INS_CLIENT_INN ELSE CL_INN END AS CL_INN, INS_CLIENT_ADDR,
					INS_CONSIG_ADDR, INS_CONSIG_NAME, INS_ID_TYPE,
					(
						SELECT TOP 1 COUR_NAME
						FROM dbo.CourierTable INNER JOIN
							dbo.TOTable ON TO_ID_COUR = COUR_ID
						WHERE TO_ID_CLIENT = INS_ID_CLIENT
						ORDER BY TO_MAIN DESC
					),
					INS_IDENT, IsNUll(ACT_DATE, CSG_DATE), IsNull(Cast(CSG_NUM AS VarChar(100)), '�/�')
				FROM	dbo.InvoiceSaleTable	A									INNER JOIN
						#inv				B	ON	A.INS_ID = B.INV_ID			INNER JOIN
						dbo.OrganizationView	C	ON	A.INS_ID_ORG=C.ORG_ID		INNER JOIN
						dbo.ClientTable			D	ON	ISNULL(A.INS_ID_PAYER, A.INS_ID_CLIENT)=D.CL_ID
						OUTER APPLY
						(
						    SELECT TOP (1)
						        ACT_DATE
						    FROM dbo.ActTable
						    WHERE ACT_ID_INVOICE = A.INS_ID
						) AS ACT
						OUTER APPLY
						(
						    SELECT TOP (1)
						        CSG_DATE, CSG_NUM
						    FROM dbo.ConsignmentTable
						    WHERE CSG_ID_INVOICE = A.INS_ID
						) AS CONS

		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail

		CREATE TABLE #detail
			(
				IFD_ID_IFM BIGINT,
				INR_ID INT,
				INR_ID_INVOICE INT,
				INR_ID_DISTR INT,
				INR_ID_PERIOD SMALLINT,
				INR_GOOD VARCHAR(150),
				INR_NAME VARCHAR(500),
				SO_INV_UNIT VARCHAR(150),
				SO_INV_OKEI VARCHAR(150),
				INR_SUM MONEY,
				INR_TNDS DECIMAL(6, 4),
				INR_SNDS MONEY,
				INR_SALL MONEY,
				INR_ID_TAX SMALLINT,
				SYS_ORDER INT,
				DIS_NUM INT,
				INR_COUNT SMALLINT
			)

		/*
		IF (SELECT TOP 1 INS_ID_TYPE FROM #master) = (SELECT INT_ID FROM dbo.InvoiceTypeTable WHERE INT_PSEDO = 'SIMPLE')
		BEGIN
			INSERT INTO #detail (
						IFD_ID_IFM,
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, INR_NAME, SO_INV_UNIT, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, SYS_ORDER, DIS_NUM, INR_COUNT
					)
				SELECT
						(
							SELECT TOP 1 IFM_ID
							FROM #master O_O
							WHERE O_O.INS_ID = B.INV_ID AND IFM_DATE = @date
						),
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, INR_NAME, INR_UNIT, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, NULL, NULL, INR_COUNT
					FROM	dbo.InvoiceRowTable		A									INNER JOIN
							#inv				B	ON	A.INR_ID_INVOICE = B.INV_ID
		END
		ELSE
		BEGIN
			INSERT INTO #detail (
						IFD_ID_IFM,
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, INR_NAME, SO_INV_UNIT, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, SYS_ORDER, DIS_NUM, INR_COUNT
					)
				SELECT
						(
							SELECT TOP 1 IFM_ID
							FROM #master O_O
							WHERE O_O.INS_ID = B.INV_ID AND IFM_DATE = @date
						),
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, SYS_NAME AS INR_NAME, INR_UNIT, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, SYS_ORDER, DIS_NUM, INR_COUNT
					FROM	dbo.InvoiceRowTable		A									INNER JOIN
							#inv				B	ON	A.INR_ID_INVOICE = B.INV_ID	LEFT OUTER JOIN
							dbo.DistrView			C	ON	A.INR_ID_DISTR=C.DIS_ID		LEFT OUTER JOIN
							dbo.SaleObjectTable		D	ON	C.SYS_ID_SO=D.SO_ID
		END
		*/

		INSERT INTO #detail (
						IFD_ID_IFM,
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, INR_NAME, SO_INV_UNIT, SO_INV_OKEI, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, SYS_ORDER, DIS_NUM, INR_COUNT
					)
				SELECT
						(
							SELECT TOP 1 IFM_ID
							FROM #master O_O
							WHERE O_O.INS_ID = B.INV_ID AND IFM_DATE = @date
						),
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, INR_NAME, INR_UNIT, UN_OKEI, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, NULL, NULL, INR_COUNT
					FROM	dbo.InvoiceRowTable		A									INNER JOIN
							#inv				B	ON	A.INR_ID_INVOICE = B.INV_ID		LEFT OUTER JOIN
							dbo.UnitTable ON UN_NAME = INR_UNIT
					WHERE INR_ID_DISTR IS NULL

				UNION ALL

				SELECT
						(
							SELECT TOP 1 IFM_ID
							FROM #master O_O
							WHERE O_O.INS_ID = B.INV_ID AND IFM_DATE = @date
						),
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD,
						CASE
							WHEN ISNULL(INR_NAME, '')  = '' THEN ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME
							WHEN INR_NAME <> ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME THEN INR_NAME
							ELSE ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME
						END AS INR_NAME, INR_UNIT, UN_OKEI, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, SYS_ORDER, DIS_NUM, INR_COUNT
					FROM	dbo.InvoiceRowTable		A									INNER JOIN
							#inv				B	ON	A.INR_ID_INVOICE = B.INV_ID	INNER JOIN
							dbo.DistrView			C WITH(NOEXPAND)	ON	A.INR_ID_DISTR=C.DIS_ID		INNER JOIN
							dbo.SaleObjectTable		D	ON	C.SYS_ID_SO=D.SO_ID		LEFT OUTER JOIN
							dbo.UnitTable ON UN_NAME = INR_UNIT

		/*
		SELECT	INS_ID,
				INS_DATE,
				INS_NUM, INS_NUM_YEAR, INS_DOC_STRING,
				ORG_SHORT_NAME, ORG_ADDRESS, ORG_INN, ORG_KPP, ORG_DIR_SHORT, ORG_BUH_SHORT,
				CL_SHORT_NAME, CL_KPP, CL_INN, INS_CLIENT_ADDR,
				INS_CONSIG_ADDR, INS_CONSIG_NAME
			FROM	dbo.InvoiceSaleTable	A									INNER JOIN
					#inv				B	ON	A.INS_ID = B.INV_ID			INNER JOIN
					dbo.OrganizationView	C	ON	A.INS_ID_ORG=C.ORG_ID		INNER JOIN
					dbo.ClientTable			D	ON	A.INS_ID_CLIENT=D.CL_ID

		SELECT	INR_ID, INR_ID_INVOICE,
				INR_NAME, SO_INV_UNIT, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL
			FROM	dbo.InvoiceRowTable		A									INNER JOIN
					#inv				B	ON	A.INR_ID_INVOICE = B.INV_ID	INNER JOIN
					dbo.DistrView			C	ON	A.INR_ID_DISTR=C.DIS_ID		INNER JOIN
					dbo.SaleObjectTable		D	ON	C.SYS_ID_SO=D.SO_ID
		*/

		IF @GROUP = 1
		BEGIN
		    IF @Print_master = 1
			    SELECT
				    IFM_ID,IFM_DATE,INS_ID,
				    --INS_ID_TYPE,
				    INT_PSEDO,
				    ORG_ID,ORG_PSEDO,ORG_FULL_NAME,ORG_SHORT_NAME,ORG_ADDRESS,ORG_INN,ORG_KPP,
				    INS_DATE,INS_NUM,INS_NUM_YEAR,
				    CL_ID,CL_PSEDO,CL_FULL_NAME,CL_SHORT_NAME,CL_INN,CL_KPP,
				    INS_CLIENT_ADDR,INS_CONSIG_NAME,INS_CONSIG_ADDR,INS_DOC_STRING,
				    ORG_DIR_SHORT,ORG_BUH_SHORT, INS_IDENT, ACT_DATE, Convert(VarChar(20), ACT_DATE, 104) AS ACT_DATE_S
			    FROM
				    #master AS IFM INNER JOIN
				    #inv ON INV_ID = INS_ID
				    LEFT JOIN dbo.InvoiceTypeTable AS ITP ON IFM.INS_ID_TYPE=ITP.INT_ID
			    WHERE IFM_DATE = @date
			    ORDER BY COUR_NAME, CL_PSEDO, CL_ID

			IF @Print_detail = 1
			    IF (SELECT TOP 1 INS_ID_TYPE FROM #master) = (SELECT INT_ID FROM dbo.InvoiceTypeTable WHERE INT_PSEDO = 'SIMPLE')
			    BEGIN
				    SELECT
				        RN = Row_Number() Over(PARTITION BY IFD_ID_IFM ORDER BY SYS_ORDER, DIS_NUM),
				        MAX_RN= SUM(1) OVER (PARTITION BY IFD_ID_IFM),
					    --INR_ID_INVOICE,	INS_ID,
					    IFD_ID_IFM,
					    CASE WHEN CL_ID = 5031 THEN '������ ���������� ����������� ������ ���������������,������������� � �������������� ��������� ������� ����������,������� �������� ����������� �� ������������ ������ ��������������� � ������ �� ���� 2020�.������������'
					    ELSE INR_GOOD END AS INR_GOOD,
					    --INR_GOOD,
					    INR_NAME, SO_INV_UNIT, SO_INV_OKEI, SUM(INR_SUM) AS INR_SUM,
					    SUM(INR_TNDS) AS INR_TNDS, SUM(INR_SNDS) AS INR_SNDS, SUM(INR_SALL) AS INR_SALL, SUM(INR_COUNT) AS INR_COUNT
				    FROM
					    #detail INNER JOIN
					    #master ON IFD_ID_IFM = IFM_ID INNER JOIN
					    #inv ON INV_ID = INS_ID
				    WHERE IFM_DATE = @date
				    GROUP BY IFD_ID_IFM, INR_GOOD, INR_NAME, SO_INV_UNIT, SO_INV_OKEI
				    ORDER BY SYS_ORDER, DIS_NUM
			    END
			    ELSE
			    BEGIN
				    SELECT
				        RN = Row_Number() Over(PARTITION BY IFD_ID_IFM ORDER BY SYS_ORDER),
				        MAX_RN= SUM(1) OVER (PARTITION BY IFD_ID_IFM),
					    --INR_ID_INVOICE,	INS_ID,
					    IFD_ID_IFM,
					    --CASE WHEN CL_ID = 5031 THEN '������ ���������� ����������� ������ ���������������,������������� � �������������� ��������� ������� ����������,������� �������� ����������� �� ������������ ������ ��������������� � ������ �� ���� 2020�.������������'
					    --ELSE INR_GOOD END AS INR_GOOD,
					    INR_GOOD,
					    INR_NAME + ' (' + CONVERT(VARCHAR(20), COUNT(*)) + ' ��)' AS INR_NAME, SO_INV_UNIT, SO_INV_OKEI, SUM(INR_SUM) AS INR_SUM,
					    INR_TNDS, SUM(INR_SNDS) AS INR_SNDS, SUM(INR_SALL) AS INR_SALL,
					    SUM(INR_COUNT) AS INR_COUNT
				    FROM
					    #detail INNER JOIN
					    #master ON IFD_ID_IFM = IFM_ID INNER JOIN
					    #inv ON INV_ID = INS_ID
				    WHERE IFM_DATE = @date
				    GROUP BY
					    --INR_ID_INVOICE, INS_ID,
					    IFD_ID_IFM, INR_GOOD, INR_NAME, INR_TNDS,
					    SO_INV_UNIT, SO_INV_OKEI, SYS_ORDER--, CL_ID
				    ORDER BY SYS_ORDER
			    END
		END
		ELSE
		BEGIN
		    IF @Print_Master = 1
			    SELECT
				    IFM_ID,IFM_DATE,INS_ID,
				    --INS_ID_TYPE,
				    INT_PSEDO,
				    ORG_ID,ORG_PSEDO,ORG_FULL_NAME,ORG_SHORT_NAME,ORG_ADDRESS,ORG_INN,ORG_KPP,
				    INS_DATE,INS_NUM,INS_NUM_YEAR,
				    CL_ID,CL_PSEDO,CL_FULL_NAME,CL_SHORT_NAME,CL_INN,CL_KPP,
				    INS_CLIENT_ADDR,INS_CONSIG_NAME,INS_CONSIG_ADDR,INS_DOC_STRING,
				    ORG_DIR_SHORT,ORG_BUH_SHORT, INS_IDENT, ACT_DATE, Convert(VarChar(20), ACT_DATE, 104) AS ACT_DATE_S, ACT_NUM
			    FROM
				    #master AS IFM INNER JOIN
				    #inv ON INV_ID = INS_ID
				    LEFT JOIN dbo.InvoiceTypeTable AS ITP ON IFM.INS_ID_TYPE=ITP.INT_ID
			    WHERE IFM_DATE = @date
			    ORDER BY COUR_NAME, CL_PSEDO, CL_ID

            IF @Print_Detail = 1
			    IF (SELECT TOP 1 INS_ID_TYPE FROM #master) = (SELECT INT_ID FROM dbo.InvoiceTypeTable WHERE INT_PSEDO = 'SIMPLE')
			    BEGIN
				    SELECT
				        RN = Row_Number() Over(PARTITION BY IFD_ID_IFM ORDER BY SYS_ORDER, DIS_NUM),
				        MAX_RN= SUM(1) OVER (PARTITION BY IFD_ID_IFM),
					    --INR_ID_INVOICE,	INS_ID,
					    IFD_ID_IFM,
					    --CASE WHEN CL_ID = 5031 THEN '������ ���������� ����������� ������ ���������������,������������� � �������������� ��������� ������� ����������,������� �������� ����������� �� ������������ ������ ��������������� � ������ �� ���� 2020�.������������'
					    --ELSE INR_GOOD END AS INR_GOOD,
					    INR_GOOD,
					    INR_NAME, SO_INV_UNIT, SO_INV_OKEI, INR_SUM,
					    INR_TNDS, INR_SNDS, INR_SALL, INR_COUNT
				    FROM
					    #detail INNER JOIN
					    #master ON IFD_ID_IFM = IFM_ID INNER JOIN
					    #inv ON INV_ID = INS_ID
				    WHERE IFM_DATE = @date
				    ORDER BY SYS_ORDER, DIS_NUM
			    END
			    ELSE
			    BEGIN
				    SELECT
				        RN = Row_Number() Over(PARTITION BY IFD_ID_IFM ORDER BY SYS_ORDER, DIS_NUM),
				        MAX_RN= SUM(1) OVER (PARTITION BY IFD_ID_IFM),
					    --INR_ID_INVOICE,	INS_ID,
					    IFD_ID_IFM,
					    --CASE WHEN CL_ID = 5031 THEN '������ ���������� ����������� ������ ���������������,������������� � �������������� ��������� ������� ����������,������� �������� ����������� �� ������������ ������ ��������������� � ������ �� ���� 2020�.������������'
					    --ELSE INR_GOOD END AS INR_GOOD,
					    INR_GOOD,
					    INR_NAME, SO_INV_UNIT, SO_INV_OKEI, SUM(INR_SUM) AS INR_SUM,
					    INR_TNDS, SUM(INR_SNDS) AS INR_SNDS, SUM(INR_SALL) AS INR_SALL,
					    INR_COUNT
				    FROM
					    #detail INNER JOIN
					    #master ON IFD_ID_IFM = IFM_ID INNER JOIN
					    #inv ON INV_ID = INS_ID
				    WHERE IFM_DATE = @date
				    GROUP BY
					    --INR_ID_INVOICE, INS_ID,
					    IFD_ID_IFM, INR_GOOD, INR_NAME, INR_ID_DISTR,
					    SO_INV_UNIT, SO_INV_OKEI, INR_TNDS, SYS_ORDER, DIS_NUM, INR_COUNT--, CL_ID
				    ORDER BY SYS_ORDER, DIS_NUM
			    END
		END


		IF @preview = 0
		BEGIN
			INSERT INTO dbo.InvoiceFactMasterTable (
						IFM_DATE,
						INS_ID,
						INS_DATE,
						INS_NUM, INS_NUM_YEAR, INS_DOC_STRING,
						ORG_ID, ORG_PSEDO, ORG_FULL_NAME,
						ORG_SHORT_NAME, ORG_ADDRESS, ORG_INN, ORG_KPP,
						ORG_DIR_SHORT, ORG_BUH_SHORT,
						CL_ID, CL_PSEDO, CL_FULL_NAME,
						CL_SHORT_NAME, CL_KPP, CL_INN, INS_CLIENT_ADDR,
						INS_CONSIG_ADDR, INS_CONSIG_NAME, INS_ID_TYPE, INS_IDENT, ACT_DATE
					)
			SELECT
					IFM_DATE,
						INS_ID,
						INS_DATE,
						INS_NUM, INS_NUM_YEAR, INS_DOC_STRING,
						ORG_ID, ORG_PSEDO, ORG_FULL_NAME,
						ORG_SHORT_NAME, ORG_ADDRESS, ORG_INN, ORG_KPP,
						ORG_DIR_SHORT, ORG_BUH_SHORT,
						CL_ID, CL_PSEDO, CL_FULL_NAME,
						CL_SHORT_NAME, CL_KPP, CL_INN, INS_CLIENT_ADDR,
						INS_CONSIG_ADDR, INS_CONSIG_NAME, INS_ID_TYPE, INS_IDENT, ACT_DATE
				FROM	#master


			INSERT INTO dbo.InvoiceFactDetailTable (
						IFD_ID_IFM,
						INR_ID, INR_ID_INVOICE,
						INR_ID_DISTR, INR_ID_PERIOD,
						INR_GOOD, INR_NAME, SO_INV_UNIT, SO_INV_OKEI, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
						INR_ID_TAX, INR_COUNT, INR_RN
					)
				SELECT
					(
						SELECT TOP 1 IFM_ID
						FROM dbo.InvoiceFactMasterTable O_O
						WHERE O_O.INS_ID = INR_ID_INVOICE AND IFM_DATE = @date
					),
					INR_ID, INR_ID_INVOICE,
					INR_ID_DISTR, INR_ID_PERIOD,
					INR_GOOD, INR_NAME, SO_INV_UNIT, SO_INV_OKEI, INR_SUM, INR_TNDS, INR_SNDS, INR_SALL,
					INR_ID_TAX, INR_COUNT,
					RN = Row_Number() Over(PARTITION BY IFD_ID_IFM ORDER BY SYS_ORDER, DIS_NUM)
				FROM	#detail B
		END

		IF OBJECT_ID('tempdb..#inv') IS NOT NULL
			DROP TABLE #inv

		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail
		IF OBJECT_ID('tempdb..#master') IS NOT NULL
			DROP TABLE #master

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INVOICE_PRINT_BY_ID_LIST] TO rl_invoice_p;
GO
