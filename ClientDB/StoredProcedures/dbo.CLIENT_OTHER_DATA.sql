USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_OTHER_DATA]
	@ID	INT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @NOW SMALLDATETIME

	SET @NOW = dbo.DateOf(GETDATE())

	DECLARE @MONTH SMALLDATETIME

	SET @MONTH = DATEADD(MONTH, -2, @NOW)

	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result

	CREATE TABLE #result
		(
			ID			INT	IDENTITY(1, 1) PRIMARY KEY,
			COMPLECT	VARCHAR(50),
			PARAM_NAME	VARCHAR(150),
			PARAM_VALUE	VARCHAR(500),
			STAT		TINYINT,
			TECH		SMALLINT,
			HOST		INT,
			DISTR		INT,
			COMP		TINYINT
		)

	IF OBJECT_ID('tempdb..#complect') IS NOT NULL
		DROP TABLE #complect
		
	CREATE TABLE #complect
		(
			UD_ID		INT PRIMARY KEY,
			UF_ID		INT,
			UD_NAME		VARCHAR(50),
			UF_DATE		DATETIME,
			UF_RES		INT,
			UF_CONS		INT,
			UD_DISTR	INT,
			UD_COMP		TINYINT,
			UD_HOST		INT
		)
		
	INSERT INTO #complect(UD_ID, UF_ID, UD_NAME, UF_DATE, UF_RES, UF_CONS, UD_DISTR, UD_COMP, UD_HOST)
		SELECT
			a.UD_ID, a.UF_ID,
			dbo.DistrString(c.SystemShortName, UD_DISTR, UD_COMP),
			UF_DATE, T.UF_ID_RES, T.UF_ID_CONS, UD_DISTR, UD_COMP, HostID
		FROM 
			USR.USRActiveView a
			INNER JOIN USR.USRFileTech t ON a.UF_ID = t.UF_ID
			INNER JOIN dbo.SystemTable c ON c.SystemID = a.UF_ID_SYSTEM AND c.SystemReg = 1 AND c.SystemRic = 20
		WHERE UD_ID_CLIENT = @ID

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT UD_NAME, PARAM_NAME, CONVERT(VARCHAR(20), DATE_S, 104), CASE WHEN DATEDIFF(DAY, DATE_S, @NOW) > 14 THEN 1 ELSE 0 END
		FROM
			(
				SELECT UD_NAME, 'Последнее пополнение' AS PARAM_NAME, UIU_DATE_S AS DATE_S
				FROM 
					#complect a
					CROSS APPLY
					(
						SELECT TOP 1 UIU_DATE_S
						FROM USR.USRIBDateView b WITH(NOEXPAND)
						WHERE a.UD_ID = b.UD_ID
							AND b.UD_ID_CLIENT = @ID
							AND UIU_DATE_S <= @NOW
						ORDER BY UIU_DATE_S DESC
					) AS D
			) AS o_O
		ORDER BY UD_NAME

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT UD_NAME, 'Версия тех.модуля', ResVersionShort, CASE IsLatest WHEN 1 THEN 0 ELSE 1 END
		FROM 
			#complect
			LEFT OUTER JOIN dbo.ResVersionTable ON ResVersionID = UF_RES
		ORDER BY UD_NAME
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT UD_NAME, 'Версия cons.exe', ConsExeVersionName, CASE ConsExeVersionActive WHEN 1 THEN 0 ELSE 1 END
		FROM 
			#complect
			LEFT OUTER JOIN dbo.ConsExeVersionTable ON ConsExeVersionID = UF_CONS
		ORDER BY UD_NAME
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT UD_NAME, 'Дата файла consult.tor', CONVERT(VARCHAR(20), UF_CONSULT_TOR, 104), 0
		FROM 
			#complect a
			LEFT OUTER JOIN USR.USRFileTech b ON a.UF_ID = b.UF_ID
		ORDER BY UD_NAME

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			UD_NAME, 'Не совпадает статистика', 
			LEFT(REVERSE(STUFF(REVERSE(
				(
					SELECT InfoBankShortName + ', '
					FROM 
						USR.USRIBComplianceView b WITH(NOEXPAND)
						INNER JOIN dbo.InfoBankTable c ON b.UI_ID_BASE = c.InfoBankID
					WHERE b.UF_ID = a.UF_ID
					ORDER BY InfoBankOrder FOR XML PATH('')
				)
			), 1, 2, '')), 500), 1
		FROM #complect a
		/*WHERE EXISTS
			(
				SELECT *
				FROM USR.USRComplianceView b WITH(NOEXPAND)
				WHERE b.UF_ID = a.UF_ID
					AND UF_COMPLIANCE = '#HOST'
			)*/
		ORDER BY UD_NAME

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			'', 'Неустановлены системы', 
			LEFT(REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ', '
					FROM 
						dbo.ClientDistrView b WITH(NOEXPAND)
					WHERE ID_CLIENT = @ID
						AND DS_REG = 0
						AND SystemBaseCheck = 1
						AND DistrTypeBaseCheck = 1
						AND NOT EXISTS
							(
								SELECT *
								FROM 
									USR.USRPackage z
									INNER JOIN #complect y ON z.UP_ID_USR = y.UF_ID
								WHERE z.UP_ID_SYSTEM = b.SystemID
									AND z.UP_DISTR = b.DISTR
									AND z.UP_COMP = b.COMP
							)
					ORDER BY SystemOrder, DISTR, COMP FOR XML PATH('')
				)
			), 1, 2, '')), 500), 1;
			
	DECLARE @IB TABLE
	(		
		ClientID			INT,
		Complect			VarCHar(100),
		ManagerName			VARCHAR(100),
		ServiceName			VARCHAR(100),
		ClientFullName		VARCHAR(512), 
		DisStr				VARCHAR(100),
		InfoBankShortName	VARCHAR(MAX), 
		InfoBankCodes		VARCHAR(MAX), 
		LAST_DATE			DATETIME,
		UF_DATE				DATETIME
	)
	
	INSERT INTO @IB
		EXEC [USR].[CLIENT_SYSTEM_AUDIT]
			@MANAGER	= NULL,
			@SERVICE	= NULL,
			@IB			= NULL,
			@DATE		= NULL,
			@CLIENT		= @ID
	
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT
			NULL, 'Отсутствуют ИБ',
			LEFT(
				REVERSE(STUFF(REVERSE(
					(
						SELECT InfoBankShortName + ' (' + DisStr + '), '
						FROM @IB
						FOR XML PATH('')
					)), 1, 2, '')),
			500), 1
		WHERE EXISTS
			(
				SELECT *
				FROM @IB
			)	

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			UD_NAME, 'Последнее обращение к серверу ИП', 
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATE, 104) + ' ' + CONVERT(VARCHAR(20), DATE, 108)
				FROM 
					IP.LogLast b
					INNER JOIN dbo.SystemTable c ON b.SYS = c.SystemNumber
				WHERE b.DISTR = a.UD_DISTR AND b.COMP = a.UD_COMP AND c.HostID = a.UD_HOST
				ORDER BY DATE DESC
			)
			, 0
		FROM #complect a
		/*WHERE EXISTS
			(
				SELECT *
				FROM 
					dbo.IPLogView b
					INNER JOIN dbo.SystemTable c ON b.LF_SYS = c.SystemNumber
				WHERE b.LF_DISTR = a.UD_DISTR AND b.LF_COMP = a.UD_COMP AND c.HostID = a.UD_HOST
			)*/
		ORDER BY UD_NAME
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT
			UD_NAME, 'Последняя сессия на ИП', 
			(
				SELECT TOP 1
					'Дата: ' + CONVERT(VARCHAR(20), CSD_START, 104) + ' ' + CONVERT(VARCHAR(20), CSD_START, 108) + ', ' + 
					'Код возврата: ' + CONVERT(VARCHAR(20), CSD_CODE_CLIENT) + ' (' +CONVERT(VARCHAR(20), CSD_CODE_CLIENT_NOTE) + '), ' +
					'Файл USR: ' + CASE CSD_USR WHEN '-' THEN 'Нет' ELSE 'Есть' END
				FROM
					IP.ClientStatDetailCache b
					INNER JOIN dbo.SystemTable c ON b.CSD_SYS = c.SystemNumber
				WHERE b.CSD_DISTR = a.UD_DISTR AND b.CSD_COMP = a.UD_COMP AND c.HostID = a.UD_HOST
				ORDER BY CSD_START DESC
			)
			, 
			CASE WHEN 
					(
						SELECT TOP 1 CSD_CODE_CLIENT 
						FROM 
							IP.ClientStatDetailCache b
							INNER JOIN dbo.SystemTable c ON b.CSD_SYS = c.SystemNumber
						WHERE b.CSD_DISTR = a.UD_DISTR AND b.CSD_COMP = a.UD_COMP AND c.HostID = a.UD_HOST
						ORDER BY CSD_START DESC
					) IN (0, 70) THEN 0 
				ELSE 1 
			END
		FROM #complect a
		/*
		WHERE EXISTS
			(
				SELECT *
				FROM 
					dbo.IPClientDetailView b
					INNER JOIN dbo.SystemTable c ON b.CSD_SYS = c.SystemNumber
				WHERE b.CSD_DISTR = a.UD_DISTR AND b.CSD_COMP = a.UD_COMP AND c.HostID = a.UD_HOST
			)*/
		ORDER BY UD_NAME
			
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			UD_NAME, 'Последняя отправка STT через ИП', 
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), ISNULL(CSD_END, CSD_START), 104) + ' ' + CONVERT(VARCHAR(20), ISNULL(CSD_END, CSD_START), 108)
				FROM 
					dbo.IPSttView b
					INNER JOIN dbo.SystemTable c ON b.CSD_SYS = c.SystemNumber
				WHERE b.CSD_DISTR = a.UD_DISTR AND b.CSD_COMP = a.UD_COMP AND c.HostID = a.UD_HOST
				ORDER BY ISNULL(CSD_END, CSD_START) DESC
			)
			, 0
		FROM #complect a
		ORDER BY UD_NAME
			
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			'', 'Заблокированы на ИП', 
			REVERSE(STUFF(REVERSE(
				(
					SELECT DistrStr + ', '
					FROM 
						dbo.ClientDistrView z WITH(NOEXPAND)
						INNER JOIN dbo.SystemTable x ON x.HostID = z.HostID
						INNER JOIN dbo.BLACK_LIST_REG y ON z.DISTR = y.DISTR AND z.COMP = y.COMP AND x.SystemID = y.ID_SYS
					WHERE z.ID_CLIENT = @ID AND z.DS_REG = 0 AND y.P_DELETE = 0
					ORDER BY x.SystemOrder, z.DISTR, z.COMP FOR XML PATH('')
				)
				), 1, 2, '')), 1
		/*FROM #complect a*/
		
		/*WHERE EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientDistrView b WITH(NOEXPAND)
					INNER JOIN dbo.BLACK_LIST_REG c ON b.SystemID = c.ID_SYS AND b.DISTR = c.DISTR AND b.COMP = c.COMP
				WHERE b.ID_CLIENT = @ID AND b.DS_REG = 0 AND c.P_DELETE = 0
			)
			*/


	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT, TECH, HOST, DISTR, COMP)		
		SELECT 
			UD_NAME, 'Последний файл cons_err', 
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), DATE, 104) + ' ' + CONVERT(VARCHAR(20), DATE, 108)
				FROM 
					IP.ConsErr b
					INNER JOIN dbo.SystemTable c ON b.SYS = c.SystemNumber
				WHERE b.DISTR = a.UD_DISTR AND b.COMP = a.UD_COMP AND c.HostID = a.UD_HOST
				ORDER BY UF_DATE DESC
			)
			, 0, 1, UD_HOST, UD_DISTR, UD_COMP
		FROM #complect a
		/*
		WHERE EXISTS
			(
				SELECT *
				FROM 
					dbo.IPConsErrView b
					INNER JOIN dbo.SystemTable c ON b.UF_SYS = c.SystemNumber
				WHERE b.UF_DISTR = a.UD_DISTR AND b.UF_COMP = a.UD_COMP AND c.HostID = a.UD_HOST
			)
			*/
		ORDER BY UD_NAME
		
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			UD_NAME, 'Максимальное ОД за 2 месяца по USR', 
			(
				SELECT MAX(T.UF_OD)
				FROM USR.USRFile b
				INNER JOIN USR.USRFIleTech t ON b.UF_ID = t.UF_ID
				WHERE UF_ID_COMPLECT = UD_ID
					AND UF_DATE >= @MONTH
			)
			, 0
		FROM #complect a	
		ORDER BY UD_NAME
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			UD_NAME, 'Максимальное количество уникальных пользователей за 2 месяца по USR', 
			(
				SELECT MAX(T.UF_UD)
				FROM USR.USRFile b
				INNER JOIN USR.USRFIleTech t ON b.UF_ID = t.UF_ID
				WHERE UF_ID_COMPLECT = UD_ID
					AND UF_DATE >= @MONTH
			)
			, 0
		FROM #complect a	
		ORDER BY UD_NAME
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)		
		SELECT 
			UD_NAME, 'Максимальное количество уникальных пользователей за 2 месяца по STT', 
			(
				SELECT COUNT(DISTINCT OTHER)				
				FROM 
					dbo.ClientStat z
					INNER JOIN dbo.SystemTable y ON z.SYS_NUM = y.SystemNumber
				WHERE HostID = UD_HOST
					AND DISTR = UD_DISTR
					AND COMP = UD_COMP
					AND DATE >= @MONTH
			)
			, 0
		FROM 
			#complect a	
		ORDER BY UD_NAME

		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT 
			UD_NAME, 'Недостаточно места на системном диске', UF_BOOT_NAME + ' (' + dbo.FileSizeToStr(UF_BOOT_FREE) + ')', 1
		FROM 
			#complect a
			INNER JOIN USR.USRFileTech b ON a.UF_ID = b.UF_ID
		WHERE UF_BOOT_FREE <= 2000
		ORDER BY UD_NAME
		
	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT 
			UD_NAME, 'Недостаточно места на диске с К+', dbo.FileSizeToStr(UF_CONS_FREE) + ', Комплект - ' + 
			UF_COMPLECT_SIZE, 1
		FROM 
			(
				SELECT 
					UD_NAME, UF_CONS_FREE, 
					USR.ComplectSize(a.UF_ID) AS UF_COMPLECT_SIZE, 
					USR.ComplectSizeMB(a.UF_ID) AS UF_COMPLECT_SIZE_MB
				FROM
					#complect a
					INNER JOIN USR.USRFileTech b ON a.UF_ID = b.UF_ID
			) AS o_O
		WHERE (UF_CONS_FREE < 2000 AND UF_COMPLECT_SIZE_MB < 4000) OR (UF_CONS_FREE < 4000 AND UF_COMPLECT_SIZE_MB >= 4000)
		ORDER BY UD_NAME		

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT 
			C.UD_NAME, 'Дистрибутивы в списке "Задать вопрос эксперту"', 
			(
				SELECT TOP (1) Convert(VarChar(20), a.SET_DATE, 104)
				FROM 
					dbo.ExpDistr a
				WHERE a.STATUS = 1
					AND a.ID_HOST = C.UD_HOST
					AND a.DISTR = C.UD_DISTR
					AND a.COMP = C.UD_COMP
					AND a.UNSET_DATE IS NULL
			),
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM USR.USRActiveView U
						INNER JOIN USR.USRFileTech T ON T.UF_ID = U.UF_ID
						WHERE C.UD_ID = U.UD_ID
							AND
							(
								T.UF_EXPCONS IS NULL AND T.UF_FORMAT >= 11
								OR
								T.UF_EXPCONS_KIND IN ('N')
							)
					) THEN 1
					ELSE 0
					END
		FROM #Complect C

	INSERT INTO #result(COMPLECT, PARAM_NAME, PARAM_VALUE, STAT)
		SELECT 
			C.UD_NAME, 'Подключен сервис "Онлайн-диалог"',
			(
				SELECT TOP (1) Convert(VarChar(20), a.SET_DATE, 104)
				FROM 
					dbo.HotlineDistr a
				WHERE a.STATUS = 1
					AND a.ID_HOST = C.UD_HOST
					AND a.DISTR = C.UD_DISTR
					AND a.COMP = C.UD_COMP
					AND a.UNSET_DATE IS NULL
			),
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM USR.USRActiveView U
						INNER JOIN USR.USRFileTech T ON T.UF_ID = U.UF_ID
						WHERE C.UD_ID = U.UD_ID
							AND
							(
								T.UF_HOTLINE IS NULL AND T.UF_FORMAT >= 11
								OR
								T.UF_HOTLINE_KIND IN ('N')
							)
					) THEN 1
					ELSE 0
					END
		FROM #Complect C
	

	SELECT *
	FROM #result 
	WHERE PARAM_VALUE IS NOT NULL
	ORDER BY ID

	IF OBJECT_ID('tempdb..#complect') IS NOT NULL
		DROP TABLE #complect
		
	IF OBJECT_ID('tempdb..#result') IS NOT NULL
		DROP TABLE #result
END

