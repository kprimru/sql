USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DBF_MERGE]
WITH EXECUTE AS OWNER
AS
BEGIN
	/*
		Слияние базы DBF и DBF_NAH

		Шаг 0: Осуществить проверки???

		Шаг 1: Обновление всех существующих клиентов.
		Шаг 2: Ввод всех новых клиентов
		Шаг 3: Обновление существующих дистрибутивов (изменение либо дистрибутива, либо клиента, которому принадлежит дистрибутив)
		Шаг 4: Ввод новых дистрибутивов
		Шаг 5: Обновление старых ТО (изменение информации или изменение принадлежности к клиенту)
		Шаг 6: Ввод новых ТО (с адресом)
		Шаг 7: Изменение сотрудников ТО
		Шаг 8: Ввод новых сотрудников ТО
	*/

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

		DECLARE @ERROR VARCHAR(MAX)

		SET @ERROR = ''

		SELECT
			@ERROR = @ERROR + 'В основной базе отсутствует клиент "' +
			CL_PSEDO + '" (' + CONVERT(VARCHAR(20), CL_NUM) + ')' + CHAR(10)
		FROM DBF_NAH.dbo.ClientTable a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.ClientTable b
				WHERE a.CL_NUM = b.CL_NUM
			)
			AND NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.ClientTable b
				WHERE a.CL_NUM = -b.CL_NUM
			)

		SELECT @ERROR = @ERROR + 'Дубликат псевдонимов в базе Находки "' + a.CL_PSEDO + '"' + CHAR(10)
		FROM
			DBF_NAH.dbo.ClientTable a
			INNER JOIN DBF.dbo.ClientTable t ON t.CL_NUM = a.CL_NUM
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.ClientTable b
				WHERE a.CL_NUM = b.CL_NUM
					AND a.CL_PSEDO = b.CL_PSEDO
			) AND
			EXISTS
			(
				SELECT *
				FROM DBF.dbo.ClientTable b
				WHERE a.CL_PSEDO = b.CL_PSEDO
			) AND EXISTS
			(
				SELECT *
				FROM DBF_NAH.dbo.TOTable w
				WHERE w.TO_ID_CLIENT = a.CL_ID
			) AND NOT EXISTS
			(
				SELECT *
				FROM
					DBF.dbo.TOTable z
				WHERE z.TO_ID_CLIENT = t.CL_ID
					AND NOT EXISTS
						(
							SELECT *
							FROM DBF_NAH.dbo.TOTable y
							WHERE a.CL_ID = y.TO_ID_CLIENT
								AND z.TO_NUM = y.TO_NUM
						)
			)

		IF @ERROR <> ''
		BEGIN
			RAISERROR (@ERROR, 16, 1)

			RETURN
		END

		INSERT INTO DBF.dbo.CityTable(CT_NAME, CT_PREFIX, CT_REGION)
			SELECT CT_NAME, CT_PREFIX, CT_REGION
			FROM DBF_NAH.dbo.CityTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.CityTable b
					WHERE a.CT_NAME = b.CT_NAME
						--AND a.CT_PREFIX = b.CT_PREFIX
				)

		INSERT INTO DBF.dbo.StreetTable(ST_PREFIX, ST_NAME, ST_SUFFIX, ST_ID_CITY, ST_ACTIVE)
			SELECT
				ST_PREFIX, ST_NAME, ST_SUFFIX,
				(
					SELECT TOP 1 CT_ID
					FROM DBF.dbo.CityTable a
					WHERE a.CT_NAME = b.CT_NAME
						--AND a.CT_PREFIX = b.CT_PREFIX
				), ST_ACTIVE
			FROM
				DBF_NAH.dbo.StreetTable c INNER JOIN
				DBF_NAH.dbo.CityTable b ON b.CT_ID = c.ST_ID_CITY
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.StreetTable d INNER JOIN
						DBF.dbo.CityTable e ON e.CT_ID = ST_ID_CITY
					WHERE d.ST_NAME = c.ST_NAME
						AND e.CT_NAME = b.CT_NAME
						AND ISNULL(d.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '')
						AND ISNULL(d.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '')
				)

		INSERT INTO DBF.dbo.SubhostTable(SH_SHORT_NAME, SH_SUBHOST, SH_LST_NAME, SH_ACTIVE, SH_ORDER)
			SELECT SH_SHORT_NAME, SH_SUBHOST, SH_LST_NAME, SH_ACTIVE, SH_ORDER
			FROM DBF_NAH.dbo.SubhostTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.SubhostTable b
					WHERE a.SH_LST_NAME <> b.SH_LST_NAME
				)

		UPDATE t
		SET t.CL_PSEDO = a.CL_PSEDO,
			t.CL_FULL_NAME = a.CL_FULL_NAME,
			t.CL_SHORT_NAME = a.CL_SHORT_NAME,
			t.CL_FOUNDING = a.CL_FOUNDING,
			t.CL_EMAIL = a.CL_EMAIL,
			t.CL_INN = a.CL_INN,
			t.CL_KPP = a.CL_KPP,
			t.CL_OKPO = a.CL_OKPO,
			t.CL_OKONX = a.CL_OKONX,
			t.CL_ACCOUNT = a.CL_ACCOUNT,
			t.CL_PHONE = a.CL_PHONE
		FROM
			DBF.dbo.ClientTable t INNER JOIN
			DBF_NAH.dbo.ClientTable a ON a.CL_NUM = t.CL_NUM LEFT OUTER JOIN
			DBF_NAH.dbo.SubhostTable c ON c.SH_ID = a.CL_ID_SUBHOST LEFT OUTER JOIN
			DBF_NAH.dbo.OrganizationTable d ON d.ORG_ID = a.CL_ID_ORG
		WHERE
				(
					a.CL_PSEDO <> t.CL_PSEDO OR
					a.CL_FULL_NAME <> t.CL_FULL_NAME OR
					ISNULL(a.CL_SHORT_NAME, '') <> ISNULL(t.CL_SHORT_NAME, '') OR
					ISNULL(a.CL_FOUNDING, '') <> ISNULL(t.CL_FOUNDING, '') OR
					ISNULL(a.CL_EMAIL, '') <> ISNULL(t.CL_EMAIL, '') OR
					ISNULL(a.CL_INN, '') <> ISNULL(t.CL_INN, '') OR
					ISNULL(a.CL_KPP, '') <> ISNULL(t.CL_KPP, '') OR
					ISNULL(a.CL_OKPO, '') <> ISNULL(t.CL_OKPO, '') OR
					ISNULL(a.CL_OKONX, '') <> ISNULL(t.CL_OKONX, '') OR
					ISNULL(a.CL_ACCOUNT, '') <> ISNULL(t.CL_ACCOUNT, '') OR
					ISNULL(a.CL_PHONE, '') <> ISNULL(t.CL_PHONE, '') OR
					ISNULL(a.CL_PHONE, '') <> ISNULL(t.CL_PHONE, '')
				) AND EXISTS
				(
					SELECT *
					FROM DBF_NAH.dbo.TOTable w
					WHERE w.TO_ID_CLIENT = a.CL_ID
				) AND NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.TOTable z
					WHERE z.TO_ID_CLIENT = t.CL_ID
						AND NOT EXISTS
							(
								SELECT *
								FROM DBF_NAH.dbo.TOTable y
								WHERE a.CL_ID = y.TO_ID_CLIENT
									AND z.TO_NUM = y.TO_NUM
							)
				) AND a.CL_NUM > 0


		INSERT INTO DBF.dbo.DistrTable(DIS_ID_SYSTEM, DIS_NUM, DIS_COMP_NUM, DIS_ACTIVE)
			SELECT e.SYS_ID, DIS_NUM, DIS_COMP_NUM, DIS_ACTIVE
			FROM
				DBF_NAH.dbo.DistrTable a INNER JOIN
				DBF_NAH.dbo.SystemTable  b ON b.SYS_ID = DIS_ID_SYSTEM INNER JOIN
				DBF.dbo.SystemTable e ON e.SYS_REG_NAME = b.SYS_REG_NAME
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.DistrTable c INNER JOIN
						DBF.dbo.SystemTable d ON d.SYS_ID = DIS_ID_SYSTEM
					WHERE c.DIS_NUM = a.DIS_NUM
						AND c.DIS_COMP_NUM = a.DIS_COMP_NUM
						AND d.SYS_REG_NAME = b.SYS_REG_NAME
				)

		UPDATE t
		SET t.DIS_ACTIVE = a.DIS_ACTIVE
		--SELECT *
		FROM
			DBF.dbo.DistrTable t INNER JOIN
			DBF_NAH.dbo.DistrTable a ON
								a.DIS_NUM = t.DIS_NUM
							AND a.DIS_COMP_NUM = t.DIS_COMP_NUM INNER JOIN
			DBF_NAH.dbo.SystemTable b ON a.DIS_ID_SYSTEM = b.SYS_ID INNER JOIN
			DBF.dbo.SystemTable c ON c.SYS_ID = t.DIS_ID_SYSTEM INNER JOIN
			DBF_NAH.dbo.HostTable d ON d.HST_ID = b.SYS_ID_HOST INNER JOIN
			DBF.dbo.HostTable e ON e.HST_ID = c.SYS_ID_HOST
		WHERE --d.HST_REG_NAME = e.HST_REG_NAME
			b.SYS_REG_NAME = c.SYS_REG_NAME
			AND a.DIS_DELIVERY = 0
			--AND a.DIS_ACTIVE <> t.DIS_ACTIVE
		--ORDER BY t.DIS_NUM

		INSERT INTO DBF.dbo.DistrServiceStatusTable(DSS_NAME, DSS_ID_STATUS, DSS_REPORT, DSS_ACTIVE)
			SELECT
				DSS_NAME,
				(
					SELECT TOP 1 DS_ID
					FROM DBF.dbo.DistrStatusTable d
					WHERE d.DS_REG = c.DS_REG
				), DSS_REPORT, DSS_ACTIVE
			FROM
				DBF_NAH.dbo.DistrServiceStatusTable a INNER JOIN
				DBF_NAH.dbo.DistrStatusTable c ON a.DSS_ID_STATUS = c.DS_ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.DistrServiceStatusTable b
					WHERE a.DSS_NAME = b.DSS_NAME
				)

		INSERT INTO DBF.dbo.ClientDistrTable(CD_ID_CLIENT, CD_ID_DISTR, CD_REG_DATE, CD_ID_SERVICE)
			SELECT
				(
					SELECT TOP 1 CL_ID
					FROM DBF.dbo.ClientTable f
					WHERE f.CL_NUM = b.CL_NUM
				),
				(
					SELECT TOP 1 DIS_ID
					FROM
						DBF.dbo.DistrTable g INNER JOIN
						DBF.dbo.SystemTable h ON h.SYS_ID = g.DIS_ID_SYSTEM
					WHERE g.DIS_NUM = c.DIS_NUM
						AND g.DIS_COMP_NUM = c.DIS_COMP_NUM
						AND h.SYS_REG_NAME = d.SYS_REG_NAME
				), CD_REG_DATE,
				(
					SELECT TOP 1 DSS_ID
					FROM DBF.dbo.DistrServiceStatusTable i
					WHERE i.DSS_NAME = 'Подхост'
				)
			FROM
				DBF_NAH.dbo.ClientDistrTable a INNER JOIN
				DBF_NAH.dbo.ClientTable b ON a.CD_ID_CLIENT = b.CL_ID INNER JOIN
				DBF_NAH.dbo.DistrTable c ON c.DIS_ID = a.CD_ID_DISTR INNER JOIN
				DBF_NAH.dbo.SystemTable d ON d.SYS_ID = c.DIS_ID_SYSTEM INNER JOIN
				DBF_NAH.dbo.DistrServiceStatusTable e ON e.DSS_ID = a.CD_ID_SERVICE
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.ClientDistrTable z INNER JOIN
						DBF.dbo.DistrTable y ON z.CD_ID_DISTR = y.DIS_ID INNER JOIN
						DBF.dbo.SystemTable x ON x.SYS_ID = y.DIS_ID_SYSTEM
					WHERE y.DIS_NUM = c.DIS_NUM
						AND y.DIS_COMP_NUM = c.DIS_COMP_NUM
						AND x.SYS_REG_NAME = d.SYS_REG_NAME
				) AND b.CL_NUM > 0

		UPDATE DBF.dbo.ClientDistrTable
		SET CD_ID_CLIENT = c.CL_ID/*,
			CD_ID_SERVICE = (SELECT DSS_ID FROM DBF.dbo.DistrServiceStatusTable WHERE DSS_NAME = 'Подхост')*/
		FROM
			DBF_NAH.dbo.ClientDistrTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON b.CL_ID = a.CD_ID_CLIENT INNER JOIN
			DBF.dbo.ClientTable c ON c.CL_NUM = b.CL_NUM INNER JOIN
			DBF_NAH.dbo.DistrTable d ON d.DIS_ID = a.CD_ID_DISTR INNER JOIN
			DBF_NAH.dbo.SystemTable e ON e.SYS_ID = d.DIS_ID_SYSTEM INNER JOIN
			DBF.dbo.SystemTable f ON f.SYS_REG_NAME = e.SYS_REG_NAME INNER JOIN
			DBF.dbo.DistrTable g ON g.DIS_NUM = d.DIS_NUM
								AND g.DIS_COMP_NUM = d.DIS_COMP_NUM
								AND g.DIS_ID_SYSTEM = f.SYS_ID
		WHERE /*DBF.dbo.ClientDistrTable.CD_ID_CLIENT <> c.CL_ID
			AND */DBF.dbo.ClientDistrTable.CD_ID_DISTR = g.DIS_ID
			AND d.DIS_DELIVERY = 0

		DELETE
		FROM DBF.dbo.ClientDistrTable
		WHERE CD_ID_DISTR IN
			(
				SELECT DIS_ID
				FROM DBF.dbo.DistrTable
				WHERE DIS_ACTIVE = 0
			)

		INSERT INTO DBF.dbo.AddressTemplateTable(ATL_CAPTION, ATL_INDEX, ATL_COUNTRY, ATL_REGION, ATL_AREA, ATL_CITY_PREFIX, ATL_CITY, ATL_STR_PREFIX, ATL_STREET, ATL_HOME, ATL_ACTIVE)
			SELECT ATL_CAPTION, ATL_INDEX, ATL_COUNTRY, ATL_REGION, ATL_AREA, ATL_CITY_PREFIX, ATL_CITY, ATL_STR_PREFIX, ATL_STREET, ATL_HOME, ATL_ACTIVE
			FROM DBF_NAH.dbo.AddressTemplateTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.AddressTemplateTable b
					WHERE a.ATL_CAPTION <> b.ATL_CAPTION
				)

		INSERT INTO	DBF.dbo.ClientAddressTable(CA_ID_CLIENT, CA_ID_TYPE, CA_INDEX, CA_ID_STREET, CA_HOME, CA_STR, CA_ID_TEMPLATE, CA_FREE)
			SELECT
				(
					SELECT TOP 1 CL_ID
					FROM DBF.dbo.ClientTable f
					WHERE f.CL_NUM = b.CL_NUM
				), CA_ID_TYPE, CA_INDEX,
				(
					SELECT TOP 1 ST_ID
					FROM
						DBF.dbo.StreetTable g INNER JOIN
						DBF.dbo.CityTable h ON h.CT_ID = g.ST_ID_CITY
					WHERE g.ST_NAME = c.ST_NAME AND h.CT_NAME = d.CT_NAME
						AND ISNULL(g.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '')
						AND ISNULL(g.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '')
				), CA_HOME, CA_STR,
				(
					SELECT TOP 1 ATL_ID
					FROM DBF.dbo.AddressTemplateTable i
					WHERE i.ATL_CAPTION = e.ATL_CAPTION
				), CA_FREE
			FROM
				DBF_NAH.dbo.ClientAddressTable a INNER JOIN
				DBF_NAH.dbo.ClientTable b ON b.CL_ID = a.CA_ID_CLIENT INNER JOIN
				DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.CA_ID_STREET INNER JOIN
				DBF_NAH.dbo.CityTable d ON d.CT_ID = c.ST_ID_CITY INNER JOIN
				DBF_NAH.dbo.AddressTemplateTable e ON e.ATL_ID = a.CA_ID_TEMPLATE
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.ClientAddressTable z INNER JOIN
						DBF.dbo.ClientTable y ON y.CL_ID = z.CA_ID_CLIENT
					WHERE z.CA_ID_TYPE = a.CA_ID_TYPE AND y.CL_NUM = b.CL_NUM
				) AND b.CL_NUM > 0

		INSERT INTO DBF.dbo.ClientFinancingAddressTable(CFA_ID_CLIENT, CFA_ID_FAT, CFA_ID_ATL)
				SELECT CA_ID_CLIENT, FAT_ID, CA_ID_TEMPLATE
				FROM
					DBF.dbo.ClientAddressTable a CROSS JOIN
					DBF.dbo.FinancingAddressTypeTable b
				WHERE ISNULL(FAT_ID_ADDR_TYPE, CA_ID_TYPE) = CA_ID_TYPE
					AND NOT EXISTS
						(
							SELECT *
							FROM DBF.dbo.ClientFinancingAddressTable
							WHERE CFA_ID_CLIENT = CA_ID_CLIENT
								AND CFA_ID_FAT = FAT_ID
						) AND CA_ID_TEMPLATE IS NOT NULL

		UPDATE DBF.dbo.ClientAddressTable
		SET DBF.dbo.ClientAddressTable.CA_INDEX = a.CA_INDEX,
			DBF.dbo.ClientAddressTable.CA_ID_STREET = i.ST_ID,
			DBF.dbo.ClientAddressTable.CA_HOME = a.CA_HOME,
			DBF.dbo.ClientAddressTable.CA_STR = a.CA_STR,
			DBF.dbo.ClientAddressTable.CA_FREE = a.CA_FREE
		FROM
			DBF_NAH.dbo.ClientAddressTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.CA_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.CA_ID_STREET INNER JOIN
			DBF_NAH.dbo.CityTable d ON d.CT_ID = c.ST_ID_CITY INNER JOIN
			DBF.dbo.ClientTable f ON f.CL_NUM = b.CL_NUM INNER JOIN
			DBF.dbo.CityTable h ON h.CT_NAME = d.CT_NAME INNER JOIN
			DBF.dbo.StreetTable i ON i.ST_ID_CITY = h.CT_ID AND i.ST_NAME = c.ST_NAME AND ISNULL(i.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '') AND ISNULL(i.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '')
		WHERE DBF.dbo.ClientAddressTable.CA_ID_CLIENT = f.CL_ID AND DBF.dbo.ClientAddressTable.CA_ID_TYPE = a.CA_ID_TYPE
			AND (
				ISNULL(DBF.dbo.ClientAddressTable.CA_INDEX, '') <> ISNULL(a.CA_INDEX, '') OR
				DBF.dbo.ClientAddressTable.CA_ID_STREET <> i.ST_ID OR
				DBF.dbo.ClientAddressTable.CA_HOME <> a.CA_HOME OR
				ISNULL(DBF.dbo.ClientAddressTable.CA_STR, '') <> ISNULL(a.CA_STR, '') OR
				ISNULL(DBF.dbo.ClientAddressTable.CA_FREE, '') <> ISNULL(a.CA_FREE, '')
			) AND b.CL_NUM > 0
			AND EXISTS
					(
						SELECT *
						FROM DBF_NAH.dbo.TOTable w
						WHERE w.TO_ID_CLIENT = b.CL_ID
					) AND NOT EXISTS
					(
						SELECT *
						FROM
							DBF.dbo.TOTable z
						WHERE z.TO_ID_CLIENT = f.CL_ID
							AND NOT EXISTS
								(
									SELECT *
									FROM DBF_NAH.dbo.TOTable y
									WHERE b.CL_ID = y.TO_ID_CLIENT
										AND z.TO_NUM = y.TO_NUM
								)
					)

		INSERT INTO DBF.dbo.PositionTable(POS_NAME, POS_ACTIVE)
			SELECT POS_NAME, POS_ACTIVE
			FROM DBF_NAH.dbo.PositionTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.PositionTable b
					WHERE a.POS_NAME = b.POS_NAME
				)

		INSERT INTO DBF.dbo.ClientPersonalTable(PER_ID_CLIENT, PER_FAM, PER_NAME, PER_OTCH, PER_ID_POS, PER_ID_REPORT_POS)
			SELECT
				(
					SELECT CL_ID
					FROM
						DBF.dbo.ClientTable z
					WHERE z.CL_NUM = b.CL_NUM
				), PER_FAM, PER_NAME, PER_OTCH,
				(
					SELECT TOP 1 POS_ID
					FROM DBF.dbo.PositionTable z
					WHERE z.POS_NAME = c.POS_NAME
				),
				(
					SELECT TOP 1 RP_ID
					FROM DBF.dbo.ReportPositionTable z
					WHERE z.RP_PSEDO = d.RP_PSEDO
				)
			FROM
				DBF_NAH.dbo.ClientPersonalTable a INNER JOIN
				DBF_NAH.dbo.ClientTable b ON b.CL_ID = a.PER_ID_CLIENT INNER JOIN
				DBF_NAH.dbo.PositionTable c ON c.POS_ID = a.PER_ID_POS INNER JOIN
				DBF_NAH.dbo.ReportPositionTable d ON d.RP_ID = a.PER_ID_REPORT_POS
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.ClientPersonalTable e INNER JOIN
						DBF.dbo.ClientTable f ON e.PER_ID_CLIENT = f.CL_ID INNER JOIN
						DBF.dbo.ReportPositionTable h ON h.RP_ID = e.PER_ID_REPORT_POS
					WHERE f.CL_NUM = b.CL_NUM AND d.RP_PSEDO = h.RP_PSEDO
				) AND b.CL_NUM > 0

		UPDATE DBF.dbo.ClientPersonalTable
		SET DBF.dbo.ClientPersonalTable.PER_FAM = a.PER_FAM,
			DBF.dbo.ClientPersonalTable.PER_NAME = a.PER_NAME,
			DBF.dbo.ClientPersonalTable.PER_OTCH = a.PER_OTCH,
			DBF.dbo.ClientPersonalTable.PER_ID_POS = f.POS_ID
		FROM
			DBF_NAH.dbo.ClientPersonalTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.PER_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.PositionTable c ON c.POS_ID = a.PER_ID_POS INNER JOIN
			DBF_NAH.dbo.ReportPositionTable d ON d.RP_ID = a.PER_ID_REPORT_POS INNER JOIN
			DBF.dbo.ClientTable e ON e.CL_NUM = b.CL_NUM INNER JOIN
			DBF.dbo.PositionTable f ON f.POS_NAME = c.POS_NAME INNER JOIN
			DBF.dbo.ReportPositionTable g ON g.RP_PSEDO = d.RP_PSEDO
		WHERE DBF.dbo.ClientPersonalTable.PER_ID_CLIENT = e.CL_ID
			AND DBF.dbo.ClientPersonalTable.PER_ID_REPORT_POS = g.RP_ID
			 AND b.CL_NUM > 0
			AND (
				DBF.dbo.ClientPersonalTable.PER_FAM <> a.PER_FAM OR
				DBF.dbo.ClientPersonalTable.PER_NAME <> a.PER_NAME OR
				DBF.dbo.ClientPersonalTable.PER_OTCH <> a.PER_OTCH OR
				ISNULL(DBF.dbo.ClientPersonalTable.PER_ID_POS, 0) <> ISNULL(f.POS_ID, 0)
			) AND EXISTS
					(
						SELECT *
						FROM DBF_NAH.dbo.TOTable w
						WHERE w.TO_ID_CLIENT = b.CL_ID
					) AND NOT EXISTS
					(
						SELECT *
						FROM
							DBF.dbo.TOTable z
						WHERE z.TO_ID_CLIENT = e.CL_ID
							AND NOT EXISTS
								(
									SELECT *
									FROM DBF_NAH.dbo.TOTable y
									WHERE b.CL_ID = y.TO_ID_CLIENT
										AND z.TO_NUM = y.TO_NUM
								)
					)

		INSERT INTO DBF.dbo.CourierTable(COUR_NAME, COUR_ACTIVE)
			SELECT COUR_NAME, COUR_ACTIVE
			FROM DBF_NAH.dbo.CourierTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.CourierTable b
					WHERE a.COUR_NAME = b.COUR_NAME
				)

		UPDATE t
		SET t.TO_ID_CLIENT = e.CL_ID,
			t.TO_NAME = a.TO_NAME,
			t.TO_REPORT = a.TO_REPORT,
			t.TO_ID_COUR = f.COUR_ID,
			t.TO_VMI_COMMENT = a.TO_VMI_COMMENT,
			t.TO_MAIN = a.TO_MAIN,
			t.TO_INN = a.TO_INN,
			t.TO_LAST = a.TO_LAST,
			t.TO_PARENT = a.TO_PARENT
		FROM
			DBF.dbo.TOTable t INNER JOIN
			DBF_NAH.dbo.TOTable a ON t.TO_NUM = a.TO_NUM INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.TO_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.CourierTable c ON c.COUR_ID  = a.TO_ID_COUR INNER JOIN
			DBF.dbo.ClientTable e ON e.CL_NUM = b.CL_NUM INNER JOIN
			DBF.dbo.CourierTable f ON f.COUR_NAME = c.COUR_NAME
		WHERE (
			t.TO_ID_CLIENT <> e.CL_ID OR
			t.TO_NAME <> a.TO_NAME OR
			t.TO_REPORT <> a.TO_REPORT OR
			ISNULL(t.TO_ID_COUR, 0) <> ISNULL(f.COUR_ID, 0) OR
			t.TO_VMI_COMMENT <> a.TO_VMI_COMMENT OR
			t.TO_MAIN <> a.TO_MAIN OR
			t.TO_INN <> a.TO_INN OR
			ISNULL(t.TO_PARENT, 0) <> ISNULL(a.TO_PARENT, 0)
			) AND b.CL_NUM > 0

		INSERT INTO DBF.dbo.TOAddressTable(TA_ID_TO, TA_INDEX, TA_ID_STREET, TA_HOME)
			SELECT
				(
					SELECT TO_ID
					FROM DBF.dbo.TOTable g
					WHERE g.TO_NUM = b.TO_NUM
				), a.TA_INDEX,
				(
					SELECT TOP 1 ST_ID
					FROM
						DBF.dbo.StreetTable h INNER JOIN
						DBF.dbo.CityTable i ON h.ST_ID_CITY = i.CT_ID
					WHERE h.ST_NAME = c.ST_NAME AND i.CT_NAME = d.CT_NAME
						AND ISNULL(h.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '')
						AND ISNULL(h.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '')
				), a.TA_HOME
			FROM
				DBF_NAH.dbo.TOAddressTable a INNER JOIN
				DBF_NAH.dbo.TOTable b ON a.TA_ID_TO = b.TO_ID INNER JOIN
				DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.TA_ID_STREET INNER JOIN
				DBF_NAH.dbo.CityTable d ON d.CT_ID = ST_ID_CITY
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.TOAddressTable e INNER JOIN
						DBF.dbo.TOTable f ON e.TA_ID_TO = f.TO_ID
					WHERE f.TO_NUM = b.TO_NUM
				)

		/*
		UPDATE DBF.dbo.TOAddressTable
		SET DBF.dbo.TOAddressTable.TA_INDEX = a.TA_INDEX,
			DBF.dbo.TOAddressTable.TA_ID_STREET = f.ST_ID,
			DBF.dbo.TOAddressTable.TA_HOME = a.TA_HOME
		FROM
			DBF_NAH.dbo.TOAddressTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON a.TA_ID_TO = b.TO_ID INNER JOIN
			DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.TA_ID_STREET INNER JOIN
			DBF_NAH.dbo.CityTable d ON d.CT_ID = c.ST_ID_CITY INNER JOIN
			DBF.dbo.CityTable e ON e.CT_NAME = d.CT_NAME INNER JOIN
			DBF.dbo.StreetTable f ON f.ST_ID_CITY = e.CT_ID AND f.ST_NAME = c.ST_NAME INNER JOIN
			DBF.dbo.TOTable g ON g.TO_NUM = b.TO_NUM
		WHERE DBF.dbo.TOAddressTable.TA_ID_TO = g.TO_ID AND (
			DBF.dbo.TOAddressTable.TA_INDEX <> a.TA_INDEX OR
			DBF.dbo.TOAddressTable.TA_ID_STREET <> f.ST_ID OR
			DBF.dbo.TOAddressTable.TA_HOME <> a.TA_HOME
			)
		*/
		UPDATE t
		SET t.TA_INDEX = a.TA_INDEX,
			t.TA_ID_STREET = f.ST_ID,
			t.TA_HOME = a.TA_HOME
		FROM
			DBF_NAH.dbo.TOAddressTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON a.TA_ID_TO = b.TO_ID INNER JOIN
			DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.TA_ID_STREET INNER JOIN
			DBF_NAH.dbo.CityTable d ON c.ST_ID_CITY = d.CT_ID INNER JOIN
			DBF.dbo.CityTable e ON e.CT_NAME = d.CT_NAME INNER JOIN
			DBF.dbo.StreetTable f ON f.ST_NAME = c.ST_NAME AND f.ST_ID_CITY = e.CT_ID AND ISNULL(f.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '') AND ISNULL(f.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '') INNER JOIN
			DBF.dbo.TOTable g ON g.TO_NUM = b.TO_NUM INNER JOIN
			DBF.dbo.TOAddressTable t ON t.TA_ID_TO = g.TO_ID
		WHERE (
			t.TA_INDEX <> a.TA_INDEX OR
			t.TA_ID_STREET <> f.ST_ID OR
			t.TA_HOME <> a.TA_HOME
			)

		INSERT INTO DBF.dbo.TODistrTable(TD_ID_DISTR, TD_ID_TO)
			SELECT
				(
					SELECT TOP 1 DIS_ID
					FROM
						DBF.dbo.DistrTable g INNER JOIN
						DBF.dbo.SystemTable h ON h.SYS_ID = g.DIS_ID_SYSTEM
					WHERE g.DIS_NUM = c.DIS_NUM
						AND g.DIS_COMP_NUM = c.DIS_COMP_NUM
						AND h.SYS_REG_NAME = d.SYS_REG_NAME
				),
				(
					SELECT TOP 1 TO_ID
					FROM DBF.dbo.TOTable f
					WHERE f.TO_NUM = b.TO_NUM
				)
			FROM
				DBF_NAH.dbo.TODistrTable a INNER JOIN
				DBF_NAH.dbo.TOTable b ON a.TD_ID_TO = b.TO_ID INNER JOIN
				DBF_NAH.dbo.DistrTable c ON c.DIS_ID = a.TD_ID_DISTR INNER JOIN
				DBF_NAH.dbo.SystemTable d ON d.SYS_ID = c.DIS_ID_SYSTEM
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.TODistrTable z INNER JOIN
						DBF.dbo.DistrTable y ON z.TD_ID_DISTR = y.DIS_ID INNER JOIN
						DBF.dbo.SystemTable x ON x.SYS_ID = y.DIS_ID_SYSTEM
					WHERE y.DIS_NUM = c.DIS_NUM
						AND y.DIS_COMP_NUM = c.DIS_COMP_NUM
						AND x.SYS_REG_NAME = d.SYS_REG_NAME
				) AND c.DIS_DELIVERY = 0 AND c.DIS_ACTIVE = 1

		UPDATE DBF.dbo.TODistrTable
		SET TD_ID_TO = c.TO_ID
		FROM
			DBF_NAH.dbo.TODistrTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON b.TO_ID = a.TD_ID_TO INNER JOIN
			DBF.dbo.TOTable c ON c.TO_NUM = b.TO_NUM INNER JOIN
			DBF_NAH.dbo.DistrTable d ON d.DIS_ID = a.TD_ID_DISTR INNER JOIN
			DBF_NAH.dbo.SystemTable e ON e.SYS_ID = d.DIS_ID_SYSTEM INNER JOIN
			DBF.dbo.SystemTable f ON f.SYS_REG_NAME = e.SYS_REG_NAME INNER JOIN
			DBF.dbo.DistrTable g ON g.DIS_NUM = d.DIS_NUM
								AND g.DIS_COMP_NUM = d.DIS_COMP_NUM
								AND g.DIS_ID_SYSTEM = f.SYS_ID
		WHERE DBF.dbo.TODistrTable.TD_ID_TO <> c.TO_ID
			AND DBF.dbo.TODistrTable.TD_ID_DISTR = g.DIS_ID
			AND d.DIS_DELIVERY = 0
			AND d.DIS_ACTIVE = 1

		DELETE
		FROM DBF.dbo.TODistrTable
		WHERE TD_ID_DISTR IN
			(
				SELECT DIS_ID
				FROM DBF.dbo.DistrTable
				WHERE DIS_ACTIVE = 0
			)

		INSERT INTO DBF.dbo.TOPersonalTable(TP_ID_TO, TP_SURNAME, TP_NAME, TP_OTCH, TP_ID_POS, TP_ID_RP, TP_PHONE, TP_LAST)
			SELECT
				(
					SELECT TO_ID
					FROM
						DBF.dbo.TOTable z
					WHERE z.TO_NUM = b.TO_NUM
				), TP_SURNAME, TP_NAME, TP_OTCH,
				(
					SELECT TOP 1 POS_ID
					FROM DBF.dbo.PositionTable z
					WHERE z.POS_NAME = c.POS_NAME
				),
				(
					SELECT TOP 1 RP_ID
					FROM DBF.dbo.ReportPositionTable z
					WHERE z.RP_PSEDO = d.RP_PSEDO
				), TP_PHONE, TP_LAST
			FROM
				DBF_NAH.dbo.TOPersonalTable a INNER JOIN
				DBF_NAH.dbo.TOTable b ON b.TO_ID = a.TP_ID_TO INNER JOIN
				DBF_NAH.dbo.PositionTable c ON c.POS_ID = a.TP_ID_POS INNER JOIN
				DBF_NAH.dbo.ReportPositionTable d ON d.RP_ID = a.TP_ID_RP
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.TOPersonalTable e INNER JOIN
						DBF.dbo.TOTable f ON e.TP_ID_TO = f.TO_ID INNER JOIN
						DBF.dbo.ReportPositionTable h ON h.RP_ID = e.TP_ID_RP
					WHERE f.TO_NUM = b.TO_NUM AND d.RP_PSEDO = h.RP_PSEDO
				)

		UPDATE DBF.dbo.TOPersonalTable
		SET DBF.dbo.TOPersonalTable.TP_SURNAME = a.TP_SURNAME,
			DBF.dbo.TOPersonalTable.TP_NAME = a.TP_NAME,
			DBF.dbo.TOPersonalTable.TP_OTCH = a.TP_OTCH,
			DBF.dbo.TOPersonalTable.TP_PHONE = a.TP_PHONE,
			DBF.dbo.TOPersonalTable.TP_ID_POS = f.POS_ID,
			DBF.dbo.TOPersonalTable.TP_LAST = a.TP_LAST
		FROM
			DBF_NAH.dbo.TOPersonalTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON a.TP_ID_TO = b.TO_ID INNER JOIN
			DBF_NAH.dbo.PositionTable c ON c.POS_ID = a.TP_ID_POS INNER JOIN
			DBF_NAH.dbo.ReportPositionTable d ON d.RP_ID = a.TP_ID_RP INNER JOIN
			DBF.dbo.TOTable e ON e.TO_NUM = b.TO_NUM INNER JOIN
			DBF.dbo.PositionTable f ON f.POS_NAME = c.POS_NAME INNER JOIN
			DBF.dbo.ReportPositionTable g ON g.RP_PSEDO = d.RP_PSEDO
		WHERE DBF.dbo.TOPersonalTable.TP_ID_TO = e.TO_ID
			AND DBF.dbo.TOPersonalTable.TP_ID_RP = g.RP_ID
			AND (
				DBF.dbo.TOPersonalTable.TP_SURNAME <> a.TP_SURNAME OR
				DBF.dbo.TOPersonalTable.TP_NAME <> a.TP_NAME OR
				DBF.dbo.TOPersonalTable.TP_OTCH <> a.TP_OTCH OR
				DBF.dbo.TOPersonalTable.TP_PHONE <> a.TP_PHONE OR
				DBF.dbo.TOPersonalTable.TP_ID_POS <> f.POS_ID
			)



		INSERT INTO DBF.dbo.DistrDeliveryHistoryTable(DDH_ID_DISTR, DDH_ID_OLD_CLIENT, DDH_ID_NEW_CLIENT, DDH_USER, DDH_DATE)
			SELECT
				(
					SELECT DIS_ID
					FROM DBF.dbo.DistrView c WITH(NOEXPAND)
					WHERE c.SYS_REG_NAME = b.SYS_REG_NAME
						AND c.DIS_NUM = b.DIS_NUM
						AND c.DIS_COMP_NUM = b.DIS_COMP_NUM
				) AS DDH_ID_DISTR,
				(
					SELECT z.CL_ID
					FROM
						DBF.dbo.ClientTable z INNER JOIN
						DBF_NAH.dbo.ClientTable y ON z.CL_NUM = y.CL_NUM
					WHERE y.CL_ID = a.DDH_ID_OLD_CLIENT
				) AS DDH_ID_OLD_CLIENT,
				(
					SELECT z.CL_ID
					FROM
						DBF.dbo.ClientTable z INNER JOIN
						DBF_NAH.dbo.ClientTable y ON z.CL_NUM = y.CL_NUM
					WHERE y.CL_ID = a.DDH_ID_NEW_CLIENT
				) AS DDH_ID_NEW_CLIENT,
				DDH_USER, DDH_DATE
			FROM
				DBF_NAH.dbo.DistrDeliveryHistoryTable a INNER JOIN
				DBF_NAH.dbo.DistrView b ON b.DIS_ID = a.DDH_ID_DISTR
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.DistrDeliveryHistoryTable z
					WHERE a.DDH_USER = z.DDH_USER
						AND a.DDH_DATE = z.DDH_DATE
						AND z.DDH_ID_DISTR =
								(
									SELECT DIS_ID
									FROM DBF.dbo.DistrView c WITH(NOEXPAND)
									WHERE c.SYS_REG_NAME = b.SYS_REG_NAME
										AND c.DIS_NUM = b.DIS_NUM
										AND c.DIS_COMP_NUM = b.DIS_COMP_NUM
								)
						AND z.DDH_ID_OLD_CLIENT =
								(
									SELECT t.CL_ID
									FROM
										DBF.dbo.ClientTable t INNER JOIN
										DBF_NAH.dbo.ClientTable q ON t.CL_NUM = q.CL_NUM
									WHERE q.CL_ID = a.DDH_ID_OLD_CLIENT
								)
						AND z.DDH_ID_NEW_CLIENT =
								(
									SELECT t.CL_ID
									FROM
										DBF.dbo.ClientTable t INNER JOIN
										DBF_NAH.dbo.ClientTable q ON t.CL_NUM = q.CL_NUM
									WHERE q.CL_ID = a.DDH_ID_NEW_CLIENT
								)
				)
				AND EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.ClientTable t INNER JOIN
						DBF_NAH.dbo.ClientTable q ON t.CL_NUM = q.CL_NUM
					WHERE q.CL_ID = a.DDH_ID_NEW_CLIENT
				)



		/*
		INSERT INTO DBF.dbo.ContractTypeTable(CTT_NAME, CTT_ACTIVE)
			SELECT CTT_NAME, CTT_ACTIVE
			FROM DBF_NAH.dbo.ContractTypeTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.ContractTypeTable b
					WHERE a.CTT_NAME = b.CTT_NAME
				)

		INSERT INTO DBF.dbo.ContractPayTable(COP_NAME, COP_DAY, COP_ACTIVE)
			SELECT COP_NAME, COP_DAY, COP_ACTIVE
			FROM DBF_NAH.dbo.ContractPayTable a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM DBF.dbo.ContractPayTable b
					WHERE a.COP_NAME = b.COP_NAME
				)

		INSERT INTO DBF.dbo.ContractTable(CO_ID_CLIENT, CO_NUM, CO_ID_TYPE, CO_DATE, CO_BEG_DATE, CO_END_DATE, CO_ACTIVE, CO_ID_PAY)
			SELECT
				(
					SELECT CL_ID
					FROM DBF.dbo.ClientTable z
					WHERE z.CL_NUM = b.CL_NUM
				),
				CO_NUM,
				(
					SELECT TOP 1 CTT_ID
					FROM DBF.dbo.ContractTypeTable z
					WHERE z.CTT_NAME = c.CTT_NAME
				),
				CO_DATE, CO_BEG_DATE, CO_END_DATE, CO_ACTIVE,
				(
					SELECT TOP 1 COP_ID
					FROM DBF.dbo.ContractPayTable z
					WHERE z.COP_NAME = d.COP_NAME
				)
			FROM
				DBF_NAH.dbo.ContractTable a INNER JOIN
				DBF_NAH.dbo.ClientTable b ON a.CO_ID_CLIENT = b.CL_ID INNER JOIN
				DBF_NAH.dbo.ContractTypeTable c ON c.CTT_ID = a.CO_ID_TYPE LEFT OUTER JOIN
				DBF_NAH.dbo.ContractPayTable d ON COP_ID = a.CO_ID_PAY
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.ContractTable e INNER JOIN
						DBF.dbo.ClientTable f ON f.CL_ID = e.CO_ID_CLIENT
					WHERE e.CO_NUM = a.CO_NUM AND f.CL_NUM = b.CL_NUM
				)

		UPDATE DBF.dbo.ContractTable
		SET	DBF.dbo.ContractTable.CO_ID_TYPE = f.CTT_ID,
			DBF.dbo.ContractTable.CO_DATE = a.CO_DATE,
			DBF.dbo.ContractTable.CO_BEG_DATE = a.CO_BEG_DATE,
			DBF.dbo.ContractTable.CO_END_DATE = a.CO_END_DATE,
			DBF.dbo.ContractTable.CO_ACTIVE = a.CO_ACTIVE,
			DBF.dbo.ContractTable.CO_ID_PAY = e.COP_ID
		FROM
			DBF_NAH.dbo.ContractTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.CO_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.ContractTypeTable c ON c.CTT_ID = a.CO_ID_TYPE LEFT OUTER JOIN
			DBF_NAH.dbo.ContractPayTable d ON d.COP_ID = a.CO_ID_PAY LEFT OUTER JOIN
			DBF.dbo.ContractPayTable e ON e.COP_NAME = d.COP_NAME INNER JOIN
			DBF.dbo.ContractTypeTable f ON f.CTT_NAME = c.CTT_NAME INNER JOIN
			DBF.dbo.ClientTable g ON b.CL_NUM = g.CL_NUM
		WHERE DBF.dbo.ContractTable.CO_NUM = a.CO_NUM AND b.CL_ID = g.CL_ID
			AND DBF.dbo.ContractTable.CO_ID_CLIENT = g.CL_ID
			AND
				(
					DBF.dbo.ContractTable.CO_ID_TYPE <> f.CTT_ID OR
					DBF.dbo.ContractTable.CO_DATE <> a.CO_DATE OR
					DBF.dbo.ContractTable.CO_BEG_DATE <> a.CO_BEG_DATE OR
					DBF.dbo.ContractTable.CO_END_DATE <> a.CO_END_DATE OR
					DBF.dbo.ContractTable.CO_ACTIVE <> a.CO_ACTIVE OR
					DBF.dbo.ContractTable.CO_ID_PAY <> e.COP_ID
				)
		*/
		/*
		DELETE t
		FROM DBF.dbo.ContractDistrTable t
		WHERE NOT EXISTS
			(
				SELECT *
				FROM
					DBF_NAH.dbo.ContractDistrTable a INNER JOIN
					DBF_NAH.dbo.ContractTable b ON b.CO_ID = a.COD_ID_CONTRACT INNER JOIN
					DBF_NAH.dbo.DistrTable c ON c.DIS_ID = a.COD_ID_DISTR INNER JOIN
					DBF_NAH.dbo.SystemTable d ON d.SYS_ID = c.DIS_ID_SYSTEM INNER JOIN
					DBF_NAH.dbo.ClientTable e ON e.CL_ID = b.CO_ID_CLIENT INNER JOIN
					DBF.dbo.SystemTable f ON f.SYS_REG_NAME = d.SYS_REG_NAME INNER JOIN
					DBF.dbo.DistrTable g ON g.DIS_ID_SYSTEM = f.SYS_ID
										AND g.DIS_NUM = c.DIS_NUM
										AND g.DIS_COMP_NUM = c.DIS_COMP_NUM INNER JOIN
					DBF.dbo.ClientTable h ON h.CL_NUM = e.CL_NUM INNER JOIN
					DBF.dbo.ContractTable i ON i.CO_ID_CLIENT = h.CL_ID AND i.CO_NUM = b.CO_NUM
				WHERE t.COD_ID_DISTR = g.DIS_ID
					AND t.COD_ID_CONTRACT = i.CO_ID
			)
		*/
		/*
		INSERT INTO DBF.dbo.ContractDistrTable(COD_ID_CONTRACT, COD_ID_DISTR)
			SELECT
				p.CO_ID, t.DIS_ID
			FROM
				DBF_NAH.dbo.ContractDistrTable a INNER JOIN
				DBF_NAH.dbo.ContractTable b ON a.COD_ID_CONTRACT = b.CO_ID INNER JOIN
				DBF_NAH.dbo.DistrTable c ON c.DIS_ID = a.COD_ID_DISTR INNER JOIN
				DBF_NAH.dbo.SystemTable d ON d.SYS_ID = c.DIS_ID_SYSTEM INNER JOIN
				DBF_NAH.dbo.ClientTable e ON e.CL_ID = b.CO_ID_CLIENT INNER JOIN
				DBF.dbo.ContractTable p ON p.CO_NUM = b.CO_NUM INNER JOIN
				DBF.dbo.ClientTable q ON q.CL_NUM = e.CL_NUM AND p.CO_ID_CLIENT = q.CL_ID INNER JOIN
				DBF.dbo.SystemTable r ON r.SYS_REG_NAME = d.SYS_REG_NAME INNER JOIN
				DBF.dbo.DistrTable t ON t.DIS_ID_SYSTEM = r.SYS_ID
									AND t.DIS_NUM = c.DIS_NUM
									AND t.DIS_COMP_NUM = c.DIS_COMP_NUM
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						DBF.dbo.ContractDistrTable z INNER JOIN
						DBF.dbo.ContractTable y ON y.CO_ID = z.COD_ID_CONTRACT INNER JOIN
						DBF.dbo.ClientTable x ON x.CL_ID = y.CO_ID_CLIENT INNER JOIN
						DBF.dbo.DistrTable w ON w.DIS_ID = z.COD_ID_DISTR INNER JOIN
						DBF.dbo.SystemTable u ON u.SYS_ID = w.DIS_ID_SYSTEM
					WHERE x.CL_NUM = e.CL_NUM AND b.CO_NUM = y.CO_NUM AND w.DIS_NUM = c.DIS_NUM
						AND w.DIS_COMP_NUM = c.DIS_COMP_NUM AND d.SYS_REG_NAME = u.SYS_REG_NAME
				)
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
GRANT EXECUTE ON [dbo].[DBF_MERGE] TO rl_dbf_merge;
GO
