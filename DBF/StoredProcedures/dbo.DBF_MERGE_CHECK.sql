USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DBF_MERGE_CHECK]
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

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

	DECLARE @ER_TBL TABLE (ID INT IDENTITY(1, 1), ERR VARCHAR(200), ERR_NOTE VARCHAR(MAX), CL_ID INT, TO_ID INT)

	INSERT INTO @ER_TBL(ERR, ERR_NOTE)
		SELECT 'Новый населенный пункт' AS ERR, 'Название: "' + CT_NAME + '", Регион: "' + CONVERT(VARCHAR(20), CT_REGION) + '"' AS ERR_NOTE
		FROM DBF_NAH.dbo.CityTable a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.CityTable b
				WHERE a.CT_NAME = b.CT_NAME
			)

		UNION ALL

		SELECT 'Новая улица', 'Название: "' + ISNULL(c.ST_PREFIX + ' ', '') + ST_NAME + ISNULL(' ' + c.ST_SUFFIX, '') + '", Населенный пункт: "' + b.CT_NAME + '"'
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

		UNION ALL

		SELECT 'Новый подхост', 'Короткое название: "' + ISNULL(SH_SHORT_NAME, '') + '", Название на РЦ: "' + ISNULL(SH_LST_NAME, '') + '"'
		FROM DBF_NAH.dbo.SubhostTable a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.SubhostTable b
				WHERE a.SH_LST_NAME <> b.SH_LST_NAME
			)
		
		UNION ALL
	
		SELECT 'Изменился клиент', 'Псевдоним: "' + t.CL_PSEDO + '". Изменились поля: ' + CHAR(10) +
			CASE 
				WHEN t.CL_PSEDO <> a.CL_PSEDO THEN 'Псевдоним с "' + t.CL_PSEDO + '" на "' + a.CL_PSEDO + '"' + CHAR(10)
				ELSE ''
			END	+
			CASE
				WHEN t.CL_FULL_NAME <> a.CL_FULL_NAME THEN 'Полное название с "' + t.CL_FULL_NAME + '" на "' + a.CL_FULL_NAME + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_SHORT_NAME, '') <> ISNULL(a.CL_SHORT_NAME, '') THEN 
							'Короткое название с "' + ISNULL(t.CL_SHORT_NAME, '') + '" на "' + ISNULL(a.CL_SHORT_NAME, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_FOUNDING, '') <> ISNULL(a.CL_FOUNDING, '') THEN 
							'Основание руководства с "' + ISNULL(t.CL_FOUNDING, '') + '" на "' + ISNULL(a.CL_FOUNDING, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_EMAIL, '') <> ISNULL(a.CL_EMAIL, '') THEN 
							'E-Mail с "' + ISNULL(t.CL_EMAIL, '') + '" на "' + ISNULL(a.CL_EMAIL, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_INN, '') <> ISNULL(a.CL_INN, '') THEN 
							'ИНН с "' + ISNULL(t.CL_INN, '') + '" на "' + ISNULL(a.CL_INN, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_KPP, '') <> ISNULL(a.CL_KPP, '') THEN 
							'КПП с "' + ISNULL(t.CL_KPP, '') + '" на "' + ISNULL(a.CL_KPP, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_OKPO, '') <> ISNULL(a.CL_OKPO, '') THEN 
							'ОКПО с "' + ISNULL(t.CL_OKPO, '') + '" на "' + ISNULL(a.CL_OKPO, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_OKONX, '') <> ISNULL(a.CL_OKONX, '') THEN 
							'ОКОНХ с "' + ISNULL(t.CL_OKONX, '') + '" на "' + ISNULL(a.CL_OKONX, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_ACCOUNT, '') <> ISNULL(a.CL_ACCOUNT, '') THEN 
							'Рассчетный счет с "' + ISNULL(t.CL_ACCOUNT, '') + '" на "' + ISNULL(a.CL_ACCOUNT, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN ISNULL(t.CL_PHONE, '') <> ISNULL(a.CL_PHONE, '') THEN 
							'Телефон с "' + ISNULL(t.CL_PHONE, '') + '" на "' + ISNULL(a.CL_PHONE, '') + '"' + CHAR(10)
				ELSE ''
			END
		FROM
			DBF.dbo.ClientTable t INNER JOIN
			DBF_NAH.dbo.ClientTable a ON a.CL_NUM = t.CL_NUM LEFT OUTER JOIN
			DBF_NAH.dbo.SubhostTable c ON c.SH_ID = a.CL_ID_SUBHOST 
		WHERE 
				(
					a.CL_PSEDO <> t.CL_PSEDO OR
					a.CL_FULL_NAME <> t.CL_FULL_NAME OR
					a.CL_SHORT_NAME <> t.CL_SHORT_NAME OR
					ISNULL(a.CL_FOUNDING, '') <> ISNULL(t.CL_FOUNDING, '') OR
					ISNULL(a.CL_EMAIL, '') <> ISNULL(t.CL_EMAIL, '') OR
					ISNULL(a.CL_INN, '') <> ISNULL(t.CL_INN, '') OR
					ISNULL(a.CL_KPP, '') <> ISNULL(t.CL_KPP, '') OR
					ISNULL(a.CL_OKPO, '') <> ISNULL(t.CL_OKPO, '') OR
					ISNULL(a.CL_OKONX, '') <> ISNULL(t.CL_OKONX, '') OR
					ISNULL(a.CL_ACCOUNT, '') <> ISNULL(t.CL_ACCOUNT, '') OR
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
				)

		UNION ALL

		SELECT 'Новые дистрибутивы', e.SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), DIS_NUM) + CASE DIS_COMP_NUM WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM) END
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
		
		UNION ALL

		SELECT 
			'Смена активности дистриубтива', 
			b.SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), t.DIS_NUM) + 
					CASE t.DIS_COMP_NUM 
						WHEN 1 THEN '' 
						ELSE '/' + CONVERT(VARCHAR(20), t.DIS_COMP_NUM) 
					END + 
			' с "' + CONVERT(VARCHAR(20), t.DIS_ACTIVE) + '" на "' + CONVERT(VARCHAR(20), a.DIS_ACTIVE) + '"'
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
			AND a.DIS_ACTIVE <> t.DIS_ACTIVE	

		UNION ALL

		SELECT 'Новый статус обслуживания', DSS_NAME
		FROM 
			DBF_NAH.dbo.DistrServiceStatusTable a INNER JOIN
			DBF_NAH.dbo.DistrStatusTable c ON a.DSS_ID_STATUS = c.DS_ID
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.DistrServiceStatusTable b 
				WHERE a.DSS_NAME = b.DSS_NAME
			)

		UNION ALL

		SELECT 'Новые дистрибутивы у клиента', 'Клиент: "' +
				(
					SELECT TOP 1 CL_PSEDO
					FROM DBF.dbo.ClientTable f
					WHERE f.CL_NUM = b.CL_NUM
				) + '". Дистрибутив: "' +
				(
					SELECT TOP 1 SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), DIS_NUM) + CASE DIS_COMP_NUM WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM) END
					FROM 
						DBF.dbo.DistrTable g INNER JOIN
						DBF.dbo.SystemTable h ON h.SYS_ID = g.DIS_ID_SYSTEM
					WHERE g.DIS_NUM = c.DIS_NUM
						AND g.DIS_COMP_NUM = c.DIS_COMP_NUM
						AND h.SYS_REG_NAME = d.SYS_REG_NAME
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
				)

		UNION ALL

		SELECT 'Переданы дистриубтивы другому клиенту', 'Старый клиент: "' + y.CL_PSEDO + '" Новый клиент: "' + c.CL_PSEDO + '"'
		FROM
			DBF_NAH.dbo.ClientDistrTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON b.CL_ID = a.CD_ID_CLIENT INNER JOIN
			DBF.dbo.ClientTable c ON c.CL_NUM = b.CL_NUM INNER JOIN
			DBF_NAH.dbo.DistrTable d ON d.DIS_ID = a.CD_ID_DISTR INNER JOIN
			DBF_NAH.dbo.SystemTable e ON e.SYS_ID = d.DIS_ID_SYSTEM INNER JOIN
			DBF.dbo.SystemTable f ON f.SYS_REG_NAME = e.SYS_REG_NAME INNER JOIN
			DBF.dbo.DistrTable g ON g.DIS_NUM = d.DIS_NUM 
								AND g.DIS_COMP_NUM = d.DIS_COMP_NUM
								AND g.DIS_ID_SYSTEM = f.SYS_ID INNER JOIN
			DBF.dbo.ClientDistrTable z ON z.CD_ID_DISTR = g.DIS_ID	INNER JOIN
			DBF.dbo.ClientTable y ON z.CD_ID_CLIENT = y.CL_ID
		WHERE d.DIS_DELIVERY = 0 AND z.CD_ID_CLIENT <> c.CL_ID

		UNION ALL

		SELECT 'Удаленные дистрибутивы клиента', 'Клиент: "' + CL_PSEDO + '", Дистрибутив: "' + DIS_STR + '"'
		FROM 
			DBF.dbo.ClientDistrTable
			INNER JOIN DBF.dbo.ClientTable ON CD_ID_CLIENT = CL_ID
			INNER JOIN DBF.dbo.DistrView ON CD_ID_DISTR = DIS_ID
		WHERE CD_ID_DISTR IN
			(
				SELECT DIS_ID
				FROM DBF.dbo.DistrTable
				WHERE DIS_ACTIVE = 0
			)

		UNION ALL	
		/*
		SELECT 'Изменился адрес', 'Клиент: "' + f.CL_PSEDO + '", Изменились поля: ' + CHAR(10) +
			CASE
				WHEN ISNULL(z.CA_INDEX, '') <> ISNULL(a.CA_INDEX, '') THEN 'Индекс с "' + ISNULL(z.CA_INDEX, '') + '" на "' + ISNULL(a.CA_INDEX, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN (ISNULL(i.ST_NAME, '') <> ISNULL(c.ST_NAME, '')) OR (ISNULL(i.ST_PREFIX, '') <> ISNULL(c.ST_PREFIX, '')) OR (ISNULL(i.ST_SUFFIX, '') <> ISNULL(c.ST_SUFFIX, '')) THEN 'Улица с "' + ISNULL(i.ST_PREFIX + ' ', '') + ISNULL(i.ST_NAME, '') + ISNULL(' ' + i.ST_SUFFIX, '') + '" на "' + ISNULL(c.ST_PREFIX + ' ', '') + ISNULL(c.ST_NAME, '') + ISNULL(' ' + c.ST_SUFFIX, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN ISNULL(z.CA_HOME, '') <> ISNULL(a.CA_HOME, '') THEN 'Дом с "' + ISNULL(z.CA_HOME, '') + '" на "' + ISNULL(a.CA_HOME, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN ISNULL(z.CA_STR, '') <> ISNULL(a.CA_STR, '') THEN 'Строка адреса с "' + ISNULL(z.CA_STR, '') + '" на "' + ISNULL(a.CA_STR, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN ISNULL(z.CA_FREE, '') <> ISNULL(a.CA_FREE, '') THEN 'Строковый адрес "' + ISNULL(z.CA_FREE, '') + '" на "' + ISNULL(a.CA_FREE, '') + '"' + CHAR(10)
				ELSE ''
			END 
		FROM 
			DBF_NAH.dbo.ClientAddressTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.CA_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.CA_ID_STREET INNER JOIN
			DBF_NAH.dbo.CityTable d ON d.CT_ID = c.ST_ID_CITY INNER JOIN
			DBF_NAH.dbo.AddressTemplateTable e ON e.ATL_ID = a.CA_ID_TEMPLATE INNER JOIN
			DBF.dbo.ClientTable f ON f.CL_NUM = b.CL_NUM INNER JOIN
			DBF.dbo.AddressTemplateTable g ON g.ATL_CAPTION = e.ATL_CAPTION INNER JOIN
			DBF.dbo.CityTable h ON h.CT_NAME = d.CT_NAME INNER JOIN
			DBF.dbo.StreetTable i ON i.ST_ID_CITY = h.CT_ID AND i.ST_NAME = c.ST_NAME AND ISNULL(i.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '') AND ISNULL(i.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '') INNER JOIN
			DBF.dbo.ClientAddressTable z ON z.CA_ID_CLIENT = f.CL_ID AND z.CA_ID_TYPE = a.CA_ID_TYPE
		WHERE 
			(
				ISNULL(z.CA_INDEX, '') <> ISNULL(a.CA_INDEX, '') OR
				z.CA_ID_STREET <> i.ST_ID OR
				ISNULL(z.CA_HOME, '') <> ISNULL(a.CA_HOME, '') OR
				ISNULL(z.CA_STR, '') <> ISNULL(a.CA_STR, '') OR
				ISNULL(z.CA_FREE, '') <> ISNULL(a.CA_FREE, '')
			)

		UNION ALL
		*/
		
		SELECT 'Новые должности', POS_NAME
		FROM DBF_NAH.dbo.PositionTable a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.PositionTable b 
				WHERE a.POS_NAME = b.POS_NAME
			)

		UNION ALL

		SELECT 'Новые сотрудники', 'Клиент: "' +
				ISNULL((
					SELECT CL_PSEDO
					FROM
						DBF.dbo.ClientTable z 
					WHERE z.CL_NUM = b.CL_NUM
				), '') + ' - ' + CONVERT(VARCHAR(20), b.CL_NUM) + '", ФИО: "' + ISNULL(PER_FAM + ' ', '') + ISNULL(PER_NAME + ' ', '') + ISNULL(PER_OTCH, '') + '" Должность: "' + ISNULL(c.POS_NAME, '') + '"'
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
			)

		UNION ALL

		SELECT 'Изменились сотрудники',	'Клиент: "' + e.CL_PSEDO + '" ' + g.RP_NAME + ' Изменились поля: ' + CHAR(10) +
			CASE	
				WHEN ISNULL(z.PER_FAM, '') <> ISNULL(a.PER_FAM, '') THEN 'Фамилия с "' + ISNULL(z.PER_FAM, '') + '" на "' + ISNULL(a.PER_FAM, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE	
				WHEN ISNULL(z.PER_NAME, '') <> ISNULL(a.PER_NAME, '') THEN 'Имя с "' + ISNULL(z.PER_NAME, '') + '" на "' + ISNULL(a.PER_NAME, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE	
				WHEN ISNULL(z.PER_OTCH, '') <> ISNULL(a.PER_OTCH, '') THEN 'Отчество с "' + ISNULL(z.PER_OTCH, '') + '" на "' + ISNULL(a.PER_OTCH, '') + '"' + CHAR(10)
				ELSE ''
			END +
			CASE	
				WHEN ISNULL(y.POS_NAME, '') <> ISNULL(f.POS_NAME, '') THEN 'Должность с "' + ISNULL(y.POS_NAME, '') + '" на "' + ISNULL(f.POS_NAME, '') + '"' + CHAR(10)
				ELSE ''
			END 		
		FROM 
			DBF_NAH.dbo.ClientPersonalTable a INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.PER_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.PositionTable c ON c.POS_ID = a.PER_ID_POS INNER JOIN
			DBF_NAH.dbo.ReportPositionTable d ON d.RP_ID = a.PER_ID_REPORT_POS INNER JOIN
			DBF.dbo.ClientTable e ON e.CL_NUM = b.CL_NUM INNER JOIN
			DBF.dbo.PositionTable f ON f.POS_NAME = c.POS_NAME INNER JOIN
			DBF.dbo.ReportPositionTable g ON g.RP_PSEDO = d.RP_PSEDO INNER JOIN
			DBF.dbo.ClientPersonalTable z ON z.PER_ID_CLIENT = e.CL_ID 
											AND z.PER_ID_REPORT_POS = g.RP_ID INNER JOIN
			DBF.dbo.PositionTable y ON y.POS_ID = z.PER_ID_POS
		WHERE (
				ISNULL(z.PER_FAM, '') <> ISNULL(a.PER_FAM, '') OR
				ISNULL(z.PER_NAME, '') <> ISNULL(a.PER_NAME, '') OR
				ISNULL(z.PER_OTCH, '') <> ISNULL(a.PER_OTCH, '') OR
				ISNULL(z.PER_ID_POS, 0) <> ISNULL(f.POS_ID, 0)
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

		UNION ALL
		
		SELECT 'Новые СИ', COUR_NAME
		FROM DBF_NAH.dbo.CourierTable a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM DBF.dbo.CourierTable b
				WHERE a.COUR_NAME = b.COUR_NAME
			)

		UNION ALL
		
		SELECT '!!!ВНИМАНИЕ! ИЗМЕНИЛСЯ КЛИЕНТ!!!', 'Номер ТО: "' + CONVERT(VARCHAR(20), t.TO_NUM) + '" с "' + e.CL_PSEDO + '" на "' + b.CL_PSEDO + '"'				
		FROM
			DBF.dbo.TOTable t INNER JOIN
			DBF_NAH.dbo.TOTable a ON t.TO_NUM = a.TO_NUM INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.TO_ID_CLIENT = b.CL_ID INNER JOIN			
			DBF.dbo.ClientTable e ON e.CL_NUM = b.CL_NUM			
		WHERE (
			t.TO_ID_CLIENT <> e.CL_ID			
			)

		UNION ALL

		SELECT 'Изменились ТО', 'Номер ТО: "' + CONVERT(VARCHAR(20), t.TO_NUM) + '" Изменились поля: ' + CHAR(10) +
			CASE
				WHEN t.TO_ID_CLIENT <> e.CL_ID THEN 'Клиент: с "' + e.CL_PSEDO + '" на "' + b.CL_PSEDO + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN t.TO_NAME <> a.TO_NAME THEN 'Название: с "' + t.TO_NAME + '" на "' + a.TO_NAME + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN t.TO_REPORT <> a.TO_REPORT THEN 'Признак вкл. в отчет: с "' + CONVERT(VARCHAR(20), t.TO_REPORT) + '" на "' + CONVERT(VARCHAR(20), a.TO_REPORT) + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN ISNULL(t.TO_ID_COUR, 0) <> ISNULL(f.COUR_ID, 0) THEN 'СИ: с "' + ISNULL(z.COUR_NAME, '') + '" на "' + ISNULL(f.COUR_NAME , '')+ '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN t.TO_VMI_COMMENT <> a.TO_VMI_COMMENT THEN 'Комментарий ВМИ: с "' + t.TO_VMI_COMMENT + '" на "' + a.TO_VMI_COMMENT + '"' + CHAR(10)
				ELSE ''
			END +
			CASE
				WHEN t.TO_INN <> a.TO_INN THEN 'ИНН: с "' + t.TO_INN + '" на "' + a.TO_INN + '"' + CHAR(10)
				ELSE ''
			END
		FROM
			DBF.dbo.TOTable t INNER JOIN
			DBF_NAH.dbo.TOTable a ON t.TO_NUM = a.TO_NUM INNER JOIN
			DBF_NAH.dbo.ClientTable b ON a.TO_ID_CLIENT = b.CL_ID INNER JOIN
			DBF_NAH.dbo.CourierTable c ON c.COUR_ID  = a.TO_ID_COUR INNER JOIN	
			DBF.dbo.ClientTable e ON e.CL_NUM = b.CL_NUM INNER JOIN	
			DBF.dbo.CourierTable f ON f.COUR_NAME = c.COUR_NAME LEFT OUTER JOIN
			DBF.dbo.CourierTable z ON z.COUR_ID = t.TO_ID_COUR
		WHERE (
			t.TO_ID_CLIENT <> e.CL_ID OR
			t.TO_NAME <> a.TO_NAME OR
			t.TO_REPORT <> a.TO_REPORT OR
			ISNULL(t.TO_ID_COUR, 0) <> ISNULL(f.COUR_ID, 0) OR
			t.TO_VMI_COMMENT <> a.TO_VMI_COMMENT OR
			t.TO_INN <> a.TO_INN
			)
		
		UNION ALL

		SELECT 'Изменился адрес точки', 'Номер ТО: "' + CONVERT(VARCHAR(20), g.TO_NUM) + '" Изменились поля: ' + CHAR(10) +
			CASE
				WHEN t.TA_INDEX <> a.TA_INDEX THEN 'Индекс с "' + t.TA_INDEX + '" на "' + a.TA_INDEX + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN t.TA_ID_STREET <> f.ST_ID THEN 'Улица с "' + ISNULL(f.ST_PREFIX + ' ', '') + ISNULL(f.ST_NAME, '') + ISNULL(' ' + f.ST_SUFFIX, '') + '" на "' + ISNULL(z.ST_PREFIX + ' ', '') + z.ST_NAME + ISNULL(' ' + z.ST_SUFFIX, '') + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE
				WHEN t.TA_HOME <> a.TA_HOME THEN 'Дом с "' + t.TA_HOME + '" на "' + a.TA_HOME + '"' + CHAR(10)
				ELSE ''
			END 			
		FROM
			DBF_NAH.dbo.TOAddressTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON a.TA_ID_TO = b.TO_ID INNER JOIN
			DBF_NAH.dbo.StreetTable c ON c.ST_ID = a.TA_ID_STREET INNER JOIN
			DBF_NAH.dbo.CityTable d ON c.ST_ID_CITY = d.CT_ID INNER JOIN	
			DBF.dbo.CityTable e ON e.CT_NAME = d.CT_NAME INNER JOIN
			DBF.dbo.StreetTable f ON f.ST_NAME = c.ST_NAME AND f.ST_ID_CITY = e.CT_ID AND ISNULL(f.ST_PREFIX, '') = ISNULL(c.ST_PREFIX, '') AND ISNULL(f.ST_SUFFIX, '') = ISNULL(c.ST_SUFFIX, '') INNER JOIN
			DBF.dbo.TOTable g ON g.TO_NUM = b.TO_NUM INNER JOIN
			DBF.dbo.TOAddressTable t ON t.TA_ID_TO = g.TO_ID INNER JOIN
			DBF.dbo.StreetTable z ON z.ST_ID = t.TA_ID_STREET
		WHERE (
			t.TA_INDEX <> a.TA_INDEX OR
			t.TA_ID_STREET <> f.ST_ID OR
			t.TA_HOME <> a.TA_HOME
			)	

		UNION ALL

		SELECT 'Новые дистрибутивы в точке', 'Номер ТО: "' + CONVERT(VARCHAR(20), b.TO_NUM) + '" Дистр: "' +
				(
					SELECT TOP 1 SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), DIS_NUM) + CASE DIS_COMP_NUM WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), DIS_COMP_NUM) END
					FROM 
						DBF.dbo.DistrTable g INNER JOIN
						DBF.dbo.SystemTable h ON h.SYS_ID = g.DIS_ID_SYSTEM
					WHERE g.DIS_NUM = c.DIS_NUM
						AND g.DIS_COMP_NUM = c.DIS_COMP_NUM
						AND h.SYS_REG_NAME = d.SYS_REG_NAME
				) + '"'			
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
				) AND c.DIS_DELIVERY = 0

		UNION ALL

		SELECT 
			'Дистрибутив перенесен в другую ТО', 'Дистрибутив: ' + 
			f.SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), g.DIS_NUM) + 
				CASE g.DIS_COMP_NUM 
					WHEN 1 THEN '' 
					ELSE '/' + CONVERT(VARCHAR(20), g.DIS_COMP_NUM) 
				END +
			' из ' + CONVERT(VARCHAR(20), y.TO_NUM) + ' в ' + CONVERT(VARCHAR(20), c.TO_NUM)	
		FROM
			DBF_NAH.dbo.TODistrTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON b.TO_ID = a.TD_ID_TO INNER JOIN
			DBF.dbo.TOTable c ON c.TO_NUM = b.TO_NUM INNER JOIN
			DBF_NAH.dbo.DistrTable d ON d.DIS_ID = a.TD_ID_DISTR INNER JOIN
			DBF_NAH.dbo.SystemTable e ON e.SYS_ID = d.DIS_ID_SYSTEM INNER JOIN
			DBF.dbo.SystemTable f ON f.SYS_REG_NAME = e.SYS_REG_NAME INNER JOIN
			DBF.dbo.DistrTable g ON g.DIS_NUM = d.DIS_NUM 
								AND g.DIS_COMP_NUM = d.DIS_COMP_NUM
								AND g.DIS_ID_SYSTEM = f.SYS_ID INNER JOIN
			DBF.dbo.TODistrTable z ON z.TD_ID_DISTR = g.DIS_ID INNER JOIN
			DBF.dbo.TOTable y ON y.TO_ID = z.TD_ID_TO
		WHERE z.TD_ID_TO <> c.TO_ID
			AND d.DIS_DELIVERY = 0

		UNION ALL

		SELECT 'Дистрибутив удален из ТО', 'Дистрибутив: "' + DIS_STR + '" ТО: ' + CONVERT(VARCHAR(20), TO_NUM)
		FROM 
			DBF.dbo.TODistrTable
			INNER JOIN DBF.dbo.TOTable ON TO_ID = TD_ID_TO
			INNER JOIN DBF.dbo.DistrView ON DIS_ID = TD_ID_DISTR
		WHERE TD_ID_DISTR IN
			(
				SELECT DIS_ID
				FROM DBF.dbo.DistrTable
				WHERE DIS_ACTIVE = 0
			)

		UNION ALL	

		SELECT 'Изменился сотрудник в ТО', 'Номер ТО: "' + CONVERT(VARCHAR(20), e.TO_NUM) + '" Изменились поля: ' + CHAR(10) +
			CASE 
				WHEN z.TP_SURNAME <> a.TP_SURNAME THEN 'Фамилия с "' + z.TP_SURNAME + '" на "' + a.TP_SURNAME + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE 
				WHEN z.TP_NAME <> a.TP_NAME THEN 'Фамилия с "' + z.TP_NAME + '" на "' + a.TP_NAME + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE 
				WHEN z.TP_OTCH <> a.TP_OTCH THEN 'Фамилия с "' + z.TP_OTCH + '" на "' + a.TP_OTCH + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE 
				WHEN z.TP_PHONE <> a.TP_PHONE THEN 'Фамилия с "' + z.TP_PHONE + '" на "' + a.TP_PHONE + '"' + CHAR(10)
				ELSE ''
			END + 
			CASE 
				WHEN z.TP_ID_POS <> f.POS_ID THEN 'Должность с "' + y.POS_NAME + '" на "' + f.POS_NAME + '"' + CHAR(10)
				ELSE ''
			END		
		FROM 
			DBF_NAH.dbo.TOPersonalTable a INNER JOIN
			DBF_NAH.dbo.TOTable b ON a.TP_ID_TO = b.TO_ID INNER JOIN
			DBF_NAH.dbo.PositionTable c ON c.POS_ID = a.TP_ID_POS INNER JOIN
			DBF_NAH.dbo.ReportPositionTable d ON d.RP_ID = a.TP_ID_RP INNER JOIN
			DBF.dbo.TOTable e ON e.TO_NUM = b.TO_NUM INNER JOIN
			DBF.dbo.PositionTable f ON f.POS_NAME = c.POS_NAME INNER JOIN
			DBF.dbo.ReportPositionTable g ON g.RP_PSEDO = d.RP_PSEDO INNER JOIN
			DBF.dbo.TOPersonalTable z ON z.TP_ID_TO = e.TO_ID INNER JOIN
			DBF.dbo.PositionTable y ON y.POS_ID = z.TP_ID_POS
		WHERE z.TP_ID_RP = g.RP_ID
			AND (
				z.TP_SURNAME <> a.TP_SURNAME OR
				z.TP_NAME <> a.TP_NAME OR
				z.TP_OTCH <> a.TP_OTCH OR
				z.TP_PHONE <> a.TP_PHONE OR
				z.TP_ID_POS <> f.POS_ID	
			)
	
	SELECT ERR, NULL AS ERR_MASTER, CONVERT(VARCHAR(MAX), COUNT(*)) AS ERR_NOTE
	FROM @ER_TBL
	GROUP BY ERR

	UNION ALL

	SELECT '', ERR, ERR_NOTE
	FROM @ER_TBL
	ORDER BY ERR, ERR_NOTE
END
