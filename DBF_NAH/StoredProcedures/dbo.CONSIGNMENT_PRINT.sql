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
ALTER PROCEDURE [dbo].[CONSIGNMENT_PRINT]
	@soid SMALLINT,
	@prid SMALLINT,
	@clid INT,
	@preview BIT,
	@courid VARCHAR(1000)
AS
BEGIN
	SET NOCOUNT ON;

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
			CFM_ID BIGINT IDENTITY(1,1) NOT NULL,
			CFM_NUM VARCHAR(50) NULL,
			CFM_FACT_DATE DATETIME NOT NULL,
			CFM_DATE SMALLDATETIME NOT NULL,
			CL_ID INT NOT NULL,
			CFM_CONSIGN_NAME VARCHAR(500),
			CFM_CONSIGN_ADDRESS VARCHAR(500),
			CFM_CONSIGN_OKPO VARCHAR(50),
			CFM_CLIENT_NAME VARCHAR(500),
			CFM_CLIENT_ADDRESS VARCHAR(500),
			CFM_FOUND VARCHAR(150),
			ORG_ID SMALLINT NOT NULL,
			ORG_SHORT_NAME VARCHAR(100) NOT NULL,
			ORG_ADDRESS VARCHAR(250) NOT NULL,
			ORG_BANK VARCHAR(150) NULL,
			ORG_ACCOUNT VARCHAR(50) NULL,
			ORG_LORO VARCHAR(50) NULL,
			ORG_BIK	VARCHAR(50) NULL,
			ORG_OKPO VARCHAR(50) NOT NULL,
			ORG_BUH_SHORT VARCHAR(150) NOT NULL,
			ORG_DIR_SHORT VARCHAR(150) NOT NULL
		)

	INSERT INTO #master
		(
			CFM_NUM, CFM_FACT_DATE, CFM_DATE, CL_ID,
			CFM_CONSIGN_NAME, CFM_CONSIGN_ADDRESS, CFM_CONSIGN_OKPO,
			CFM_CLIENT_NAME, CFM_CLIENT_ADDRESS,
			CFM_FOUND, ORG_ID, ORG_SHORT_NAME, ORG_ADDRESS, ORG_BANK, ORG_ACCOUNT,
			ORG_LORO, ORG_BIK, ORG_OKPO, ORG_BUH_SHORT, ORG_DIR_SHORT
		)
	SELECT
		CSG_NUM, @curdate, CSG_DATE,
		CL_ID,
		CSG_CONSIGN_NAME, CSG_CONSIGN_ADDRESS, CSG_CONSIGN_OKPO, CSG_CLIENT_NAME, CSG_CLIENT_ADDRESS,
		CSG_FOUND,
		ORG_ID, ORG_SHORT_NAME, 
		(ORG_INDEX + ', ' + a.CT_PREFIX + a.CT_NAME + ', ' + a.ST_PREFIX + a.ST_NAME + ',' + ORG_HOME + ' ���. ' + ORG_PHONE) AS ORG_ADDRESS,
		--ORG_S_INDEX, b.ST_PREFIX AS ST_S_PREFIX, b.ST_NAME AS ST_S_NAME,
		--b.CT_PREFIX AS CT_S_PREFIX, b.CT_NAME AS CT_S_NAME, ORG_S_HOME,
		ORG_ACCOUNT, BA_NAME AS ORG_BANK, ORG_BIK, ORG_LORO, ORG_OKPO,
		--ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH,
		(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT,
		(ORG_DIR_FAM + ' ' + LEFT(ORG_DIR_NAME, 1) + '.' + LEFT(ORG_DIR_OTCH, 1) + '.') AS ORG_DIR_SHORT
		--ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
	FROM
		dbo.ConsignmentTable INNER JOIN
		--dbo.PeriodTable ON PR_ID = BL_ID_PERIOD INNER JOIN
		dbo.ClientTable ON CL_ID = CSG_ID_CLIENT LEFT OUTER JOIN 
		dbo.ClientAddressTable ON CL_ID = CA_ID_CLIENT LEFT OUTER JOIN
		dbo.AddressView d ON CA_ID_STREET = ST_ID LEFT OUTER JOIN
		dbo.OrganizationTable ON ORG_ID = CSG_ID_ORG LEFT OUTER JOIN
		dbo.AddressView a ON a.ST_ID = ORG_ID_STREET LEFT OUTER JOIN
		dbo.AddressView b ON b.ST_ID = ORG_S_ID_STREET LEFT OUTER JOIN
		dbo.BankTable ON BA_ID = ORG_ID_BANK LEFT OUTER JOIN
		dbo.CityTable c ON c.CT_ID = BA_ID_CITY	LEFT OUTER JOIN
		-- 16.06.2009, ��� ���� ������
		dbo.ClientAddressView Z ON ClientAddressTable.CA_ID=Z.CA_ID	LEFT OUTER JOIN
		dbo.FinancingAddressTypeTable Y ON Z.CA_ID_TYPE = Y.FAT_ID_ADDR_TYPE 
	WHERE 
		-- 3.06.09 ������� �.�. ������� ���� - �� ������, ���� � ������� �� �������� ������������ ��� ��� ������ ���������������
		 --16.06.2009
			--ISNULL(Z.CA_ID_TYPE, 3) = 3
			FAT_DOC='CONS'

		--AND PR_DATE >= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @prid)
		--AND PR_ID = @prid
		AND CL_ID = ISNULL(@clid, CL_ID)

	IF OBJECT_ID('tempdb..#detail') IS NOT NULL
		DROP TABLE #detail

	CREATE TABLE #detail
		(
			CFD_ID_CFM BIGINT NOT NULL,
			CSM_ID_CLIENT INT NOT NULL,
			CSD_NUM SMALLINT NULL,
			CSD_NAME VARCHAR(150) NOT NULL,
			CSD_STR VARCHAR(50) NOT NULL,
			DIS_ID INT NULL,
			DIS_STR VARCHAR(20) NULL,
			CSD_CODE VARCHAR(50) NULL,
			CSD_UNIT VARCHAR(100) NULL,
			CSD_OKEI VARCHAR(50) NULL,
			CSD_PACKING VARCHAR(50) NULL,
			CSD_COUNT_IN_PLACE VARCHAR(50) NULL,
			CSD_PLACE VARCHAR(50) NULL,
			CSD_MASS VARCHAR(50) NULL,
			CSD_COUNT SMALLINT NULL,
			CSD_COST MONEY NOT NULL,
			CSD_PRICE MONEY NOT NULL,
			CSD_TAX_PRICE MONEY NOT NULL,
			CSD_TOTAL_PRICE MONEY NOT NULL,
			CSD_PAYED_PRICE MONEY NULL,
			TX_PERCENT DECIMAL(8, 4) NOT NULL,
			TX_NAME VARCHAR(50) NOT NULL
		)

	INSERT INTO #detail
		(
			CFD_ID_CFM, CSM_ID_CLIENT, CSD_NUM, CSD_STR, CSD_NAME, DIS_ID, DIS_STR,
			CSD_CODE, CSD_UNIT, CSD_OKEI, CSD_PACKING, CSD_COUNT_IN_PLACE, CSD_PLACE,
			CSD_MASS, CSD_COUNT, CSD_COST, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE,
			CSD_PAYED_PRICE, TX_PERCENT, TX_NAME
		)
	SELECT
		(
			SELECT CFM_ID
			FROM #master
			WHERE CFM_FACT_DATE = @curdate AND CL_ID = CSG_ID_CLIENT
		),
		CSG_ID_CLIENT, CSD_NUM, GD_NAME AS CSD_STR,
		SYS_NAME AS CSD_NAME, a.DIS_ID, a.DIS_STR, CSD_CODE,
		CSD_UNIT, CSD_OKEI, CSD_PACKING, CSD_COUNT_IN_PLACE, CSD_PLACE, CSD_MASS,
		CSD_COUNT, CSD_COST, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE,
		CSD_PAYED_PRICE, TX_PERCENT, TX_NAME
	FROM
		dbo.ConsignmentDetailTable INNER JOIN
		dbo.ConsignmentTable ON CSD_ID_CONS = CSG_ID INNER JOIN
		#cour ON COUR_ID =
			ISNULL((SELECT TOP 1 TO_ID_COUR FROM dbo.TOTable WHERE TO_ID_CLIENT = CSG_ID_CLIENT ORDER BY TO_ID_COUR), COUR_ID) INNER JOIN
		dbo.DistrView a WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR INNER JOIN
		dbo.DistrDocumentView b ON a.DIS_ID = b.DIS_ID INNER JOIN
		dbo.SaleObjectTable ON SYS_ID_SO = SO_ID INNER JOIN
		dbo.TaxTable ON TX_ID = SO_ID_TAX
	WHERE 
		SYS_ID_SO = @soid
		AND DOC_PSEDO = 'CONS'
		AND DD_PRINT = 1
		-- 3.06.09 ������� �.�. ������� ���� - �� ������, ���� � ������� �� �������� ������������ ��� ��� ������ ���������������
		--AND --16.06.2009
			--ISNULL(Z.CA_ID_TYPE, 3) = 3
			--FAT_DOC='bill-pay'
		AND CSG_ID_CLIENT = ISNULL(@clid, CSG_ID_CLIENT)
	ORDER BY CSD_NUM

	IF @preview <> 1
	BEGIN
		INSERT INTO dbo.ConsignmentFactMasterTable
			(
				CFM_NUM, CFM_FACT_DATE, CFM_DATE, CL_ID,
				CFM_CONSIGN_NAME, CFM_CONSIGN_ADDRESS, CFM_CONSIGN_OKPO,
				CFM_CLIENT_NAME, CFM_CLIENT_ADDRESS,
				CFM_FOUND, ORG_ID, ORG_SHORT_NAME, ORG_ADDRESS, ORG_BANK, ORG_BIK, ORG_LORO, ORG_OKPO,
				ORG_BUH_SHORT, ORG_DIR_SHORT
			)
		SELECT
				CFM_NUM, @curdate, CFM_DATE, CL_ID,
				CFM_CONSIGN_NAME, CFM_CONSIGN_ADDRESS, CFM_CONSIGN_OKPO,
				CFM_CLIENT_NAME, CFM_CLIENT_ADDRESS,
				CFM_FOUND, ORG_ID, ORG_SHORT_NAME, ORG_ADDRESS, ORG_BANK, ORG_BIK, ORG_LORO, ORG_OKPO,
				ORG_BUH_SHORT, ORG_DIR_SHORT
		FROM #master
		WHERE EXISTS
			(
				SELECT * FROM #detail WHERE CFM_ID = CFD_ID_CFM
			)

		INSERT INTO dbo.ConsignmentFactDetailTable
			(
				CFD_ID_CFM, CSD_NUM, CSD_NAME, CSD_STR, DIS_ID, DIS_STR, CSD_CODE,
				CSD_UNIT, CSD_OKEI, CSD_PACKING, CSD_COUNT_IN_PLACE, CSD_PLACE, CSD_MASS,
				CSD_COUNT, CSD_COST, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME
			)
			SELECT
				(
					SELECT CFM_ID
					FROM dbo.ConsignmentFactMasterTable
					WHERE CFM_FACT_DATE = @curdate AND CL_ID = CSM_ID_CLIENT
				), CSD_NUM, CSD_NAME, CSD_STR, DIS_ID, DIS_STR, CSD_CODE,
				CSD_UNIT, CSD_OKEI, CSD_PACKING, CSD_COUNT_IN_PLACE, CSD_PLACE, CSD_MASS,
				CSD_COUNT, CSD_COST, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME
			FROM #detail
	END

	SELECT *,
		(
			SELECT TOP 1 TO_ID_COUR
			FROM dbo.TOTable
			WHERE TO_ID_CLIENT = CL_ID
			ORDER BY TO_MAIN DESC
		) AS COUR_ID
	FROM #master
	WHERE EXISTS
			(
				SELECT * FROM #detail WHERE CFM_ID = CFD_ID_CFM
			)
	ORDER BY COUR_ID


	SELECT *
	FROM #detail
	ORDER BY CFD_ID_CFM, CSD_NUM

	IF OBJECT_ID('tempdb..#cour') IS NOT NULL
		DROP TABLE #cour
	IF OBJECT_ID('tempdb..#master') IS NOT NULL
		DROP TABLE #master
	IF OBJECT_ID('tempdb..#detail') IS NOT NULL
		DROP TABLE #detail
END
GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_PRINT] TO rl_consignment_p;
GO