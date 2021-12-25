USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_PRINT_BY_ID_LIST]
    @actidlist  VarChar(MAX),
    @preview    Bit = 1,
    @contract   Int = null,
    @group      Bit = 0,
    @apply      Bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @date           DateTime;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        SET @date = GetDate();

        IF OBJECT_ID('tempdb..#act') IS NOT NULL
            DROP TABLE #act;

        CREATE TABLE #act
        (
            [ACT_ID]            Int NOT NULL,
            PRIMARY KEY CLUSTERED([ACT_ID])
        );

        INSERT INTO #act
        SELECT *
        FROM dbo.GET_TABLE_FROM_LIST(@actidlist, ',');

        INSERT INTO [dbo].[FinancingProtocol]([ID_CLIENT], [ID_DOCUMENT], [TP], [OPER], [TXT])
        SELECT ACT_ID_CLIENT, a.ACT_ID, 'ACT', 'Печать акта', ''
        FROM #act               AS a
        INNER JOIN [dbo].[ActTable] AS b ON a.[ACT_ID] = b.[ACT_ID]

        IF OBJECT_ID('tempdb..#master') IS NOT NULL
            DROP TABLE #master;

        CREATE TABLE #master
        (
            AFM_ID                  Int     IDENTITY(1,1),
            AFM_DATE                DateTime,
            ACT_ID                  Int,
            CL_ID                   Int,
            CL_PSEDO                VarChar(50),
            CL_FULL_NAME            VarChar(500),
            CL_SHORT_NAME           VarChar(200),
            CL_FOUNDING             VarChar(500),
            CO_ID                   Int,
            CO_NUM                  VarChar(500),
            CO_DATE                 SmallDateTime,
            CO_KEY                  VarChar(256),
            CO_NUM_FROM             VarChar(256),
            CO_NUM_TO               VarChar(256),
            CO_EMAIL                VarChar(256),
            CK_HEADER               VarChar(50),
            CK_CENTER               VarChar(50),
            CK_FOOTER               VarChar(50),
            CK_CREATIVE             VarChar(50),
            CK_PREPOSITIONAL        VarChar(50),
            POS_NAME                VarChar(150),
            PER_FAM                 VarChar(250),
            PER_NAME                VarChar(50),
            PER_OTCH                VarChar(50),
            ORG_ID                  SmallInt,
            ORG_FULL_NAME           VarChar(250),
            ORG_SHORT_NAME          VarChar(50),
            ORG_INN                 VarChar(50),
            ORG_KPP                 VarChar(50),
            ORG_ACCOUNT             VarChar(50),
            ORG_LORO                VarChar(50),
            ORG_BIK                 VarChar(50),
            ORG_DIR_FAM             VarChar(50),
            ORG_DIR_NAME            VarChar(50),
            ORG_DIR_OTCH            VarChar(50),
            ORG_DIR_SHORT           VarChar(50),
            BA_NAME                 VarChar(150),
            PR_MONTH                VarChar(15),
            PR_DATE                 SmallDateTime,
            PR_END_DATE             SmallDateTime,
            COUR_NAME               VarChar(100),
            ACT_TO                  Bit,
            TAX_STR                 Decimal(8, 4),
            IsOnline                Bit,
            IsLongService           Bit,
            PRIMARY KEY CLUSTERED ([AFM_ID])
        );

		INSERT INTO #master (
					AFM_DATE,
					ACT_ID,
					CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
					CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL,
					CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL,
					POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
					ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME,
					ORG_INN, ORG_KPP, ORG_ACCOUNT, ORG_LORO, ORG_BIK,
					ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
					BA_NAME,
					PR_MONTH, PR_DATE,
					PR_END_DATE, COUR_NAME, ACT_TO, TAX_STR, IsOnline, IsLongService
					)
			SELECT
					@date,
					a.ACT_ID,
					a.ACT_ID_CLIENT, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
					CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL,CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL,
					POS_NAME, LEFT(PER_FAM, 150), LEFT(PER_NAME, 50), LEFT(PER_OTCH, 50),
					ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME,
					ORG_INN, ORG_KPP, ISNULL(ORGC_ACCOUNT, ORG_ACCOUNT), BA_LORO, BA_BIK,
					ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
					(ORG_DIR_FAM + ' ' + LEFT(ORG_DIR_NAME, 1) + '.' + LEFT(ORG_DIR_OTCH, 1) + '.')
						AS ORG_DIR_SHORT,
					BA_NAME,
					(
						SELECT TOP 1 DATENAME(MM, PR_DATE)
						FROM dbo.PeriodTable
						WHERE PR_ID IN
							(
								SELECT AD_ID_PERIOD
								FROM dbo.ActDistrTable
								WHERE AD_ID_ACT = Y.ACT_ID
							)
						ORDER BY PR_DATE DESC
					) AS PR_MONTH,
					(
						SELECT TOP 1 PR_DATE
						FROM dbo.PeriodTable
						WHERE PR_ID IN
							(
								SELECT AD_ID_PERIOD
								FROM dbo.ActDistrTable
								WHERE AD_ID_ACT = Y.ACT_ID
							)
						ORDER BY PR_DATE DESC
					) AS PR_DATE,
					ACT_DATE AS PR_END_DATE,
					(
						SELECT TOP 1 COUR_NAME
						FROM
							dbo.CourierTable INNER JOIN
							dbo.TOTable ON TO_ID_COUR = COUR_ID
						WHERE TO_ID_CLIENT = ACT_ID_CLIENT
						ORDER BY TO_MAIN DESC
					),
					CASE WHEN @apply = 1 THEN 1 ELSE ACT_TO END,
					(
						SELECT TOP 1 TX_PERCENT
						FROM
							dbo.ActDistrTable
							INNER JOIN dbo.TaxTable ON TX_ID = AD_ID_TAX
						WHERE AD_ID_ACT = A.ACT_ID
						ORDER BY TX_ID
					), a.IsOnline, a.IsLongService
			FROM dbo.ActTable a
			INNER JOIN #act y ON y.ACT_ID = a.ACT_ID
			INNER JOIN dbo.ClientTable b ON ISNULL(a.ACT_ID_PAYER, a.ACT_ID_CLIENT) = b.CL_ID
			LEFT OUTER JOIN dbo.ClientPersonalTable	e ON e.PER_ID_CLIENT = b.CL_ID AND ISNULL(PER_ID_REPORT_POS, 1) = 1
			LEFT OUTER JOIN dbo.PositionTable f ON e.PER_ID_POS = f.POS_ID
			LEFT OUTER JOIN dbo.OrganizationTable g ON ISNULL(a.ACT_ID_ORG, b.CL_ID_ORG) = g.ORG_ID
			LEFT OUTER JOIN dbo.OrganizationCalc	J	ON  j.ORGC_ID		=	B.CL_ID_ORG_CALC
			LEFT OUTER JOIN dbo.BankTable h ON ISNULL(j.ORGC_ID_BANK, g.ORG_ID_BANK) = h.BA_ID
			OUTER APPLY
			(
				SELECT TOP 1 p.CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL, CK_HEADER, CK_FOOTER, CK_CENTER, CK_CREATIVE, CK_PREPOSITIONAL
				FROM
					(
						SELECT 1 AS TP, @contract AS CO_ID
						WHERE @contract IS NOT NULL

						UNION ALL

						SELECT TOP 1 2 AS TP, CO_ID
						FROM
							dbo.ContractTable INNER JOIN
							dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID INNER JOIN
							dbo.ActDistrTable ON AD_ID_DISTR = COD_ID_DISTR AND AD_ID_ACT = A.ACT_ID
						WHERE CO_ID_CLIENT = ACT_ID_CLIENT
							AND ACT_DATE BETWEEN CO_BEG_DATE AND ISNULL(CO_END_DATE, '20500101')
						ORDER BY CO_DATE DESC, CO_ACTIVE DESC

						UNION ALL

						SELECT TOP 1 3 AS TP, CO_ID
						FROM
							dbo.ContractTable INNER JOIN
							dbo.ContractDistrTable ON COD_ID_CONTRACT = CO_ID INNER JOIN
							dbo.ActDistrTable ON AD_ID_DISTR = COD_ID_DISTR AND AD_ID_ACT = A.ACT_ID
						WHERE CO_ID_CLIENT = ACT_ID_CLIENT AND CO_ACTIVE = 1
					) AS o_O
					INNER JOIN dbo.ContractTable p ON p.CO_ID = o_O.CO_ID
					INNER JOIN dbo.ContractKind ON CK_ID = CO_ID_KIND
				ORDER BY TP
			) AS t;

		DELETE
		FROM #master
		WHERE NOT EXISTS
			(
				SELECT *
				FROM
					dbo.ActDistrTable INNER JOIN
					dbo.ContractDistrTable ON COD_ID_DISTR = AD_ID_DISTR INNER JOIN
					dbo.ContractTable ON CO_ID = COD_ID_CONTRACT
				WHERE AD_ID_ACT = ACT_ID
					AND CO_ID_CLIENT = CL_ID
			);

		IF OBJECT_ID('tempdb..#detail') IS NOT NULL
			DROP TABLE #detail;

		CREATE TABLE #detail
			(
				AFD_ID_AFM bigint,
				ACT_ID	int,
				PR_ID smallint,
				PR_DATE smalldatetime,
				PR_MONTH varchar(50),
				PR_END_DATE smalldatetime,
				DIS_ID int,
				DIS_NUM varchar(50),
				SYS_NAME varchar(250),
				SYS_ORDER int,
				AD_PRICE money,
				AD_TAX_PRICE money,
				AD_TOTAL_PRICE money,
				TX_PERCENT decimal,
				TX_NAME varchar(50),
				SO_ID smallint,
				SO_BILL_STR varchar(250),
				SO_INV_UNIT varchar(150),
				AD_PAYED_PRICE money,
				TO_NUM	INT,
				TO_NAME	VARCHAR(255),
				SYS_ADD VarChar(512),
				DF_EXPIRE SmallDateTime
			)

		INSERT INTO #detail (
				AFD_ID_AFM, ACT_ID,
				PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
				DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
				AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME,
				SO_ID, SO_BILL_STR, SO_INV_UNIT,
				AD_PAYED_PRICE, TO_NUM, TO_NAME, SYS_ADD, DF_EXPIRE
				)
			SELECT
					(
						SELECT TOP 1 AFM_ID
						FROM #master AS O_O
						WHERE AFM_DATE = @date AND O_O.ACT_ID = Y.ACT_ID
					), A.ACT_ID,
					AD_ID_PERIOD, I.PR_DATE,
					(
						SELECT TOP 1 DATENAME(MM, PR_DATE)
						FROM dbo.PeriodTable
						WHERE PR_ID IN
							(
								SELECT AD_ID_PERIOD
								FROM dbo.ActDistrTable
								WHERE AD_ID_ACT = Y.ACT_ID
							)
						ORDER BY PR_DATE DESC
					) AS PR_MONTH,
					I.PR_END_DATE,
					AD_ID_DISTR, DIS_NUM, CASE ISNULL(DF_NAME, '') WHEN '' THEN ISNULL(SYS_PREFIX, '') + ' ' + SYS_NAME ELSE DF_NAME END, SYS_ORDER,
					AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
					TX_PERCENT, TX_NAME,
					SO_ID,
					--CASE WHEN A.ACT_ID_CLIENT = 5031 THEN 'Услуги пополнения экземпляров Систем КонсультантПлюс,установленных в подразделениях Заказчика объемом информации,который поступил Исполнителю от Разработчика Систем КонсультантПлюс с января по июль 2020г.включительно'
					--ELSE GD_NAME END,
					GD_NAME, --SO_BILL_STR,
					UN_NAME, --SO_INV_UNIT,
					AD_PAYED_PRICE,
					(
						SELECT TOP 1 TO_NUM
						FROM
							dbo.TODistrTable INNER JOIN
							dbo.TOTable ON TO_ID = TD_ID_TO
						WHERE TD_ID_DISTR = AD_ID_DISTR
					),
					(
						SELECT TOP 1 TO_NAME
						FROM
							dbo.TODistrTable INNER JOIN
							dbo.TOTable ON TO_ID = TD_ID_TO
						WHERE TD_ID_DISTR = AD_ID_DISTR
					),
					CASE WHEN z.IsOnline = 1 AND A.ACT_DATE > '20210801' THEN ' (в т.ч. специальной копии системы)' ELSE '' END AS SYS_ADD,
					z.AD_EXPIRE
				FROM dbo.ActTable               AS A
				INNER JOIN #act                 AS Y    ON Y.ACT_ID     = A.ACT_ID
				INNER JOIN dbo.ActDistrTable    AS Z    ON Z.AD_ID_ACT  = A.ACT_ID
				INNER JOIN dbo.PeriodTable      AS I    ON Z.AD_ID_PERIOD = I.PR_ID
				INNER JOIN dbo.DistrView        AS B WITH(NOEXPAND) ON Z.AD_ID_DISTR = B.DIS_ID
				INNER JOIN dbo.SaleObjectTable  AS C    ON B.SYS_ID_SO = C.SO_ID
				INNER JOIN dbo.TaxTable         AS D    ON D.TX_ID = C.SO_ID_TAX
				INNER JOIN dbo.DistrDocumentView AS E   ON E.DIS_ID = B.DIS_ID
				LEFT JOIN dbo.DistrFinancingTable AS DF ON DF_ID_DISTR = e.DIS_ID
				WHERE DOC_PSEDO = 'ACT'
				    AND DD_PRINT = 1;

		DELETE FROM #detail
		WHERE AFD_ID_AFM IS NULL;

		IF @GROUP = 1
			SELECT
				AFM_ID, AFM_DATE, ACT_ID, CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
				CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL, CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL,
				POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
				ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INN, ORG_KPP, ORG_ACCOUNT,
				ORG_LORO, ORG_BIK, ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
				BA_NAME, PR_MONTH, PR_END_DATE, 0 AS ACT_TO, TAX_STR,
				ACT_TOTAL_PRICE = dbo.MoneyFormat((SELECT SUM(AD_TOTAL_PRICE) FROM #detail WHERE AFD_ID_AFM = AFM_ID)),
				IsOnline, IsLongService
			FROM #master
			ORDER BY COUR_NAME, CL_PSEDO, CL_ID
		ELSE
			SELECT
				AFM_ID, AFM_DATE, ACT_ID, CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
				CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL, CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL,
				POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
				ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INN, ORG_KPP, ORG_ACCOUNT,
				ORG_LORO, ORG_BIK, ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
				BA_NAME, PR_MONTH, PR_END_DATE, ACT_TO, TAX_STR,
				ACT_TOTAL_PRICE = dbo.MoneyFormat((SELECT SUM(AD_TOTAL_PRICE) FROM #detail WHERE AFD_ID_AFM = AFM_ID)),
				IsOnline, IsLongService
			FROM #master
			ORDER BY COUR_NAME, CL_PSEDO, CL_ID

		IF @GROUP = 1
			SELECT
				AFD_ID_AFM, ACT_ID,
				--PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
				NULL AS DIS_ID, CONVERT(VARCHAR(20), COUNT(*)) + ' шт' AS DIS_NUM, SYS_NAME, SYS_ORDER,
				SUM(AD_PRICE) AS AD_PRICE, SUM(AD_TAX_PRICE) AS AD_TAX_PRICE,
				SUM(AD_TOTAL_PRICE) AS AD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME, SO_ID,
				SO_BILL_STR, SO_INV_UNIT, SUM(AD_PAYED_PRICE) AS AD_PAYED_PRICE,
				NULL AS TO_NUM, NULL AS TO_NAME, SYS_ADD, DF_EXPIRE = Convert(VarChar(20), DF_EXPIRE, 104)
			FROM #detail
			GROUP BY
				ACT_ID, AFD_ID_AFM, /*DIS_ID, DIS_NUM, */SYS_NAME, SYS_ORDER, SYS_ADD, DF_EXPIRE,
				TX_PERCENT, TX_NAME,
				SO_ID, SO_INV_UNIT, SO_BILL_STR/*, TO_NUM, TO_NAME*/
			ORDER BY AFD_ID_AFM, /*TO_NUM, */SYS_ORDER/*, DIS_NUM	*/
		ELSE
			SELECT
				AFD_ID_AFM, ACT_ID,
				--PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
				DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
				SUM(AD_PRICE) AS AD_PRICE, SUM(AD_TAX_PRICE) AS AD_TAX_PRICE,
				SUM(AD_TOTAL_PRICE) AS AD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME, SO_ID,
				SO_BILL_STR, SO_INV_UNIT, SUM(AD_PAYED_PRICE) AS AD_PAYED_PRICE,
				TO_NUM, TO_NAME, SYS_ADD, DF_EXPIRE = Convert(VarChar(20), DF_EXPIRE, 104)
			FROM #detail
			GROUP BY
				ACT_ID, AFD_ID_AFM, DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER, SYS_ADD, DF_EXPIRE,
				TX_PERCENT, TX_NAME,
				SO_ID, SO_INV_UNIT, SO_BILL_STR, TO_NUM, TO_NAME
			ORDER BY AFD_ID_AFM, TO_NUM, SYS_ORDER, DIS_NUM

		--IF @preview = 0
		--BEGIN
			INSERT INTO dbo.ActFactMasterTable (
				AFM_DATE, CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
				CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL, CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL,
				POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
				ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INN, ORG_KPP,
				ORG_ACCOUNT, ORG_LORO, ORG_BIK,
				ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
				BA_NAME,
				PR_MONTH, PR_END_DATE, ACT_ID, ACT_TO, TAX_STR, IsOnline, IsLongService
					)
			SELECT
				AFM_DATE, CL_ID, CL_PSEDO, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
				CO_ID, CO_NUM, CO_DATE, CO_KEY, CO_NUM_FROM, CO_NUM_TO, CO_EMAIL, CK_HEADER, CK_CENTER, CK_FOOTER, CK_CREATIVE, CK_PREPOSITIONAL,
				POS_NAME, PER_FAM, PER_NAME, PER_OTCH,
				ORG_ID, ORG_FULL_NAME, ORG_SHORT_NAME, ORG_INN, ORG_KPP,
				ORG_ACCOUNT, ORG_LORO, ORG_BIK,
				ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH, ORG_DIR_SHORT,
				BA_NAME,
				PR_MONTH, PR_END_DATE, ACT_ID, ACT_TO, TAX_STR, IsOnline, IsLongService
			FROM	#master;

			INSERT INTO dbo.ActFactDetailTable (
				AFD_ID_AFM,
				PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
				DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
				AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
				TX_PERCENT, TX_NAME,
				SO_ID, SO_BILL_STR, SO_INV_UNIT,
				AD_PAYED_PRICE, TO_NUM, TO_NAME
					)
				SELECT
					(
						SELECT TOP 1 AFM_ID
						FROM dbo.ActFactMasterTable O_O
						WHERE O_O.ACT_ID = B.ACT_ID AND
							AFM_DATE = @date
					),
					PR_ID, PR_DATE, PR_MONTH, PR_END_DATE,
					DIS_ID, DIS_NUM, SYS_NAME, SYS_ORDER,
					AD_PRICE, AD_TAX_PRICE, AD_TOTAL_PRICE,
					TX_PERCENT, TX_NAME,
					SO_ID, SO_BILL_STR, SO_INV_UNIT,
					AD_PAYED_PRICE, TO_NUM, TO_NAME
				FROM	#detail AS B;

		DROP TABLE #act
		DROP TABLE #master
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
GRANT EXECUTE ON [dbo].[ACT_PRINT_BY_ID_LIST] TO rl_act_p;
GO
