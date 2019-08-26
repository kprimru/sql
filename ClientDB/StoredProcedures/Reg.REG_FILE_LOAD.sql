USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[REG_FILE_LOAD]
	@REG	NVARCHAR(512) = NULL,
	@UPDATE	BIT = 1
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @SAVE NVARCHAR(500) /* путь для сохраненного файла*/

	DECLARE @PROCESS_DATE	DATETIME

	IF @REG IS NULL
	BEGIN
		SET @PROCESS_DATE = GETDATE()

		SET @SAVE = 'C:\DATA\REG_CLIENT\Client\reg' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(50), @PROCESS_DATE, 121), '-', ''), ':', ''), ' ', ''), '.', '') + '.csv'

		DECLARE @CMD NVARCHAR(1024)

		--SET @CMD = Maintenance.GlobalConsregPath() + ' /outcsvex:' + @SAVE + ' /BASE* /ALL'
		SET @CMD = Maintenance.GlobalConsregPath() + ' /outcsvex1:' + @SAVE + ' /BASE* /ALL'


		DECLARE @RESULT INT
		EXEC @RESULT = master..xp_cmdshell @CMD, NO_OUTPUT

		IF (@RESULT <> 0)
			RETURN
	END
	ELSE
	BEGIN
		SET @SAVE = @REG

		IF CHARINDEX('\', @REG) > 0
		BEGIN
			SET @REG = REVERSE(@REG)
			
			SET @REG = LEFT(@REG, CHARINDEX('\', @REG) - 1)

			SET @REG = REVERSE(@REG)
		END
				
		IF LEN(@REG) = 24 AND LEFT(@REG, 3) = 'REG'
			SELECT @PROCESS_DATE =  
				CONVERT(DATETIME,
					SUBSTRING(A, 1, 4) + '-' + SUBSTRING(A, 5, 2) + '-' + SUBSTRING(A, 7, 2) + ' ' + 
					SUBSTRING(A, 9, 2) + ':' + SUBSTRING(A, 11, 2) + ':' + SUBSTRING(A, 13, 2) + '.' + SUBSTRING(A, 15, 3),
					121)
			FROM
				(
					 SELECT SUBSTRING(@REG, 4, 17) AS A
				) AS o_O
		ELSE
			SET @PROCESS_DATE = GETDATE()
	END

	IF OBJECT_ID('tempdb..#tp') IS NOT NULL
		DROP TABLE #tp

	CREATE TABLE #tp
		(
			RW	VARCHAR(MAX)
		)

	SET @sql = '
				BULK INSERT #tp
				FROM ''' + @SAVE + '''	
				WITH 
					(
						CODEPAGE = 1251,
						LASTROW = 1	
					)
				'	

	EXEC sp_executesql @sql

	DECLARE @COLCOUNT SMALLINT

	SELECT @COLCOUNT = LEN(RW) - LEN(REPLACE(RW, ';', ''))
	FROM #tp	
		
	IF OBJECT_ID('tempdb..#tp') IS NOT NULL
		DROP TABLE #tp

	DECLARE @BCP_PATH NVARCHAR(512)
	DECLARE @TYPE	VARCHAR(20)

	IF @COLCOUNT = 12
	BEGIN
		SET @BCP_PATH = 'C:\DATA\REG_CLIENT\bcp.fmt'
		SET @TYPE = 'SIMPLE'
	END
	ELSE IF @COLCOUNT = 22
	BEGIN
		SET @BCP_PATH = 'C:\DATA\REG_CLIENT\bcp_ex.fmt'
		SET @TYPE = 'EX'
	END
	ELSE IF @COLCOUNT = 25
	BEGIN
		SET @BCP_PATH = 'C:\DATA\REG_CLIENT\bcp_ex1.fmt'
		SET @TYPE = 'EX2'
	END
	ELSE
	BEGIN
		RAISERROR('Невнятный файл какой-то подсунули мне, подонки!', 16, 1)
		RETURN
	END

	DECLARE @ERROR	VARCHAR(MAX)

	IF OBJECT_ID('tempdb..#reg') IS NOT NULL
		DROP TABLE #reg

	CREATE TABLE #reg
		(
			SYS_NAME	VARCHAR(20),
				DISTR		INT,
				COMP		TINYINT,
				DIS_TYPE	VARCHAR(20),
				TECH_TYPE	SMALLINT,
				NET			SMALLINT,
				SUBHOST		SMALLINT,
				TRANS_COUNT	SMALLINT,
				TRANS_LEFT	SMALLINT,
				SERVICE		SMALLINT,
				REG_DATE	VARCHAR(20),
				FIRST_REG	VARCHAR(20),
				COMMENT		VARCHAR(255),
				COMPLECT	VARCHAR(50),
				REP_CODE	VARCHAR(10),
				REP_VALUE	VARCHAR(50),
				SYS_SHORT	VARCHAR(10),
				SYS_MAIN	TINYINT,
				SYS_SUB		TINYINT,
				OFFLINE		VARCHAR(50),
				YUBIKEY		VARCHAR(50),
				KRF			VARCHAR(50),
				KRF1		VARCHAR(50),
				ADDPARAM	VARCHAR(20),
				ODON		VARCHAR(20),
				ODOFF		VARCHAR(20)
		)

	IF @TYPE = 'SIMPLE'
	BEGIN
		IF OBJECT_ID('tempdb..#reg_simple') IS NOT NULL
			DROP TABLE #reg_simple

		CREATE TABLE #reg_simple
			(
				SYS_NAME	VARCHAR(20),
				DISTR		INT,
				COMP		TINYINT,
				DIS_TYPE	VARCHAR(20),
				TECH_TYPE	SMALLINT,
				NET			INT,
				SUBHOST		SMALLINT,
				TRANS_COUNT	INT,
				TRANS_LEFT	INT,
				SERVICE		SMALLINT,
				REG_DATE	VARCHAR(20),
				COMMENT		VARCHAR(255),
				COMPLECT	VARCHAR(50)
			)

		SET @SQL = '
			BULK INSERT #reg_simple
			FROM ''' + @SAVE + '''
			WITH
				(
					FORMATFILE = ''' + @BCP_PATH + ''',
					FIRSTROW = 2
				)'
		EXEC sp_executesql @SQL

		INSERT INTO #reg(SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, FIRST_REG, COMMENT, COMPLECT)
			SELECT SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, NULL, COMMENT, COMPLECT
			FROM #reg_simple

		IF OBJECT_ID('tempdb..#reg_simple') IS NOT NULL
			DROP TABLE #reg_simple
	END
	ELSE IF @TYPE = 'EX'
	BEGIN
		IF OBJECT_ID('tempdb..#reg_ex') IS NOT NULL
			DROP TABLE #reg_ex

		CREATE TABLE #reg_ex
			(
				SYS_NAME	VARCHAR(20),
				DISTR		INT,
				COMP		TINYINT,
				DIS_TYPE	VARCHAR(20),
				TECH_TYPE	SMALLINT,
				NET			SMALLINT,
				SUBHOST		SMALLINT,
				TRANS_COUNT	SMALLINT,
				TRANS_LEFT	SMALLINT,
				SERVICE		SMALLINT,
				REG_DATE	VARCHAR(20),
				FIRST_REG	VARCHAR(20),
				COMMENT		VARCHAR(255),
				COMPLECT	VARCHAR(50),
				REP_CODE	VARCHAR(10),
				REP_VALUE	VARCHAR(50),
				SYS_SHORT	VARCHAR(10),
				SYS_MAIN	TINYINT,
				SYS_SUB		TINYINT,
				SYS_OFFLINE	VARCHAR(50),
				YUBIKEY		VARCHAR(50),
				KRF			VARCHAR(50),
				KRF1		VARCHAR(50)
			)

		SET @SQL = '
			BULK INSERT #reg_ex
			FROM ''' + @SAVE + '''
			WITH
				(
					FORMATFILE = ''' + @BCP_PATH + ''',
					FIRSTROW = 2
				)'
		EXEC sp_executesql @SQL

		INSERT INTO #reg(SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, FIRST_REG, COMMENT, COMPLECT, OFFLINE)
			SELECT SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, FIRST_REG, COMMENT, COMPLECT, SYS_OFFLINE
			FROM #reg_ex

		IF OBJECT_ID('tempdb..#reg_ex') IS NOT NULL
			DROP TABLE #reg_ex
	END
	ELSE IF @TYPE = 'EX2'
	BEGIN
		IF OBJECT_ID('tempdb..#reg_ex2') IS NOT NULL
			DROP TABLE #reg_ex2

		CREATE TABLE #reg_ex2
			(
				SYS_NAME	VARCHAR(20),
				DISTR		INT,
				COMP		TINYINT,
				DIS_TYPE	VARCHAR(20),
				TECH_TYPE	SMALLINT,
				NET			SMALLINT,
				SUBHOST		SMALLINT,
				TRANS_COUNT	SMALLINT,
				TRANS_LEFT	SMALLINT,
				SERVICE		SMALLINT,
				REG_DATE	VARCHAR(20),
				FIRST_REG	VARCHAR(20),
				COMMENT		VARCHAR(255),
				COMPLECT	VARCHAR(50),
				REP_CODE	VARCHAR(10),
				REP_VALUE	VARCHAR(50),
				SYS_SHORT	VARCHAR(10),
				SYS_MAIN	TINYINT,
				SYS_SUB		TINYINT,
				SYS_OFFLINE	VARCHAR(50),
				YUBIKEY		VARCHAR(50),
				KRF			VARCHAR(50),
				KRF1		VARCHAR(50),
				ADDPARAM	VARCHAR(20),
				ODON		VARCHAR(20),
				ODOFF		VARCHAR(20)
			)

		SET @SQL = '
			BULK INSERT #reg_ex2
			FROM ''' + @SAVE + '''
			WITH
				(
					FORMATFILE = ''' + @BCP_PATH + ''',
					FIRSTROW = 2
				)'
		EXEC sp_executesql @SQL

		INSERT INTO #reg--(SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, FIRST_REG, COMMENT, COMPLECT, OFFLINE)
			SELECT *--SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, FIRST_REG, COMMENT, COMPLECT, SYS_OFFLINE
			FROM #reg_ex2

		IF OBJECT_ID('tempdb..#reg_ex2') IS NOT NULL
			DROP TABLE #reg_ex2
	END

	CREATE UNIQUE CLUSTERED INDEX [IX_CLUST] ON #reg (SYS_NAME, DISTR, COMP)	

	IF @REG IS NULL
	BEGIN
		SET @CMD = 'DEL ' + @SAVE
		
		EXEC master..xp_cmdshell @CMD, NO_OUTPUT
	END

	UPDATE #reg
	SET COMMENT = REPLACE(LEFT(RIGHT(COMMENT, LEN(COMMENT) - 1), LEN(COMMENT) - 2), '""', '"')
	WHERE SUBSTRING(COMMENT, 1, 1) = '"' AND SUBSTRING(COMMENT, LEN(COMMENT), 1) = '"'

	UPDATE #reg
	SET ODON = 0
	WHERE ODON IS NULL
	
	UPDATE #reg
	SET ODOFF = 0
	WHERE ODOFF IS NULL
		
	SELECT @ERROR = TP + ': ' + MSG + CHAR(10)
	FROM 
		(
			SELECT DISTINCT 'Неизвестная система' AS TP, SYS_NAME AS MSG
			FROM #reg
			WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.SystemTable
						WHERE SYS_NAME = SystemBaseName
					)
		
			UNION ALL

			SELECT DISTINCT 'Не указан хост системы', SystemShortName
			FROM 
				dbo.SystemTable
				INNER JOIN #reg ON SYS_NAME = SystemBaseName
			WHERE HostID IS NULL

			UNION ALL

			SELECT DISTINCT 'Неизвестный тип системы', DIS_TYPE
			FROM #reg
			WHERE NOT EXISTS
					(
						SELECT *
						FROM Din.SystemType
						WHERE DIS_TYPE = SST_REG
					)

			UNION ALL

			SELECT DISTINCT 'Неизвестная сетевитость', 'Сеть ' + CONVERT(VARCHAR(20), NET) + ' Тех ' + CONVERT(VARCHAR(20), TECH_TYPE) + ' ОДОН ' + CONVERT(VARCHAR(20), ODOn) + ' ОДОфф ' + CONVERT(VARCHAR(20), ODOff)  
			FROM #reg 
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Din.NetType
					WHERE NT_TECH = TECH_TYPE AND NT_NET = NET
						AND NT_ODON = ODON AND NT_ODOFF = ODOFF
				)

			UNION ALL

			SELECT DISTINCT 'Неизвестный статус', CONVERT(VARCHAR(20), SERVICE)
			FROM #reg
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.DistrStatus
					WHERE DS_REG = SERVICE
				)
		) AS o_O
				
	IF @ERROR IS NOT NULL
	BEGIN
		PRINT @ERROR
	
		EXEC Maintenance.MAIL_SEND @ERROR
	
		IF OBJECT_ID('tempdb..#reg') IS NOT NULL
			DROP TABLE #reg

		RETURN
	END

	/* заполняем новыми дистрибутивами основную таблицу*/
	INSERT INTO Reg.RegDistr(ID_HOST, DISTR, COMP, STATUS, CREATE_DATE)
		SELECT HostID, DISTR, COMP, 1, @PROCESS_DATE
		FROM 
			#reg a
			INNER JOIN dbo.SystemTable ON SystemBaseName = SYS_NAME
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Reg.RegDistr b
				WHERE ID_HOST = HostID
					AND b.DISTR = a.DISTR
					AND b.COMP = a.COMP
			)

	/* если есть кому сменить статус в основной таблице - меняем
	 вернуть в активный список*/
	UPDATE a
	SET STATUS = 1
	FROM Reg.RegDistr a
	WHERE STATUS = 2
		AND EXISTS
			(
				SELECT *
				FROM 
					#reg b
					INNER JOIN dbo.SystemTable ON SystemBaseName = SYS_NAME
				WHERE a.ID_HOST = HostID
					AND a.DISTR = b.DISTR
					AND a.COMP = b.COMP
			)
	/* или удалить из списка*/
	UPDATE a
	SET STATUS = 2
	FROM Reg.RegDistr a
	WHERE STATUS = 1
		AND NOT EXISTS
			(
				SELECT *
				FROM 
					#reg b
					INNER JOIN dbo.SystemTable ON SystemBaseName = SYS_NAME
				WHERE a.ID_HOST = HostID
					AND a.DISTR = b.DISTR
					AND a.COMP = b.COMP
			)		

	/* добавляем записи в таблицу истории, делая все предыдущие записи этого дистрибутива неактивными*/
	INSERT INTO Reg.RegHistory(
					ID_DISTR, DATE, ID_SYSTEM, ID_NET, ID_TYPE, SUBHOST, TRAN_COUNT, TRAN_LEFT,
					ID_STATUS, REG_DATE, FIRST_REG, COMPLECT, COMMENT, OFFLINE
				)
		SELECT 
			z.ID, @PROCESS_DATE, b.SystemID, c.NT_ID, d.SST_ID, SUBHOST, TRANS_COUNT, TRANS_LEFT,
			e.DS_ID, CONVERT(SMALLDATETIME, REG_DATE, 104), CONVERT(SMALLDATETIME, FIRST_REG, 104), COMPLECT, COMMENT, OFFLINE
		FROM 
			#reg a
			INNER JOIN dbo.SystemTable b ON b.SystemBaseName = a.SYS_NAME
			INNER JOIN Din.NetType c ON c.NT_NET = a.NET AND c.NT_TECH = a.TECH_TYPE AND c.NT_ODON = a.ODON AND c.NT_ODOFF = a.ODOFF
			INNER JOIN Din.SystemType d ON d.SST_REG = a.DIS_TYPE
			INNER JOIN dbo.DistrStatus e ON e.DS_REG = a.SERVICE
			INNER JOIN Reg.RegDistr z ON  z.ID_HOST = b.HostID
					AND z.DISTR = a.DISTR
					AND z.COMP = a.COMP
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Reg.RegDistr q
				CROSS APPLY
				(
					SELECT TOP 1 *
					FROM Reg.RegHistory t
					WHERE t.ID_DISTR = q.ID
					ORDER BY DATE DESC, ID DESC
				) t
				WHERE t.ID_DISTR = z.ID
					AND t.ID_SYSTEM = b.SystemID
					AND t.ID_NET = c.NT_ID
					AND t.ID_TYPE = d.SST_ID
					AND t.SUBHOST = a.SUBHOST
					AND t.TRAN_LEFT = a.TRANS_LEFT
					AND t.TRAN_COUNT = a.TRANS_COUNT
					AND t.ID_STATUS = e.DS_ID
					AND ISNULL(t.REG_DATE, @PROCESS_DATE) = ISNULL(CONVERT(SMALLDATETIME, a.REG_DATE, 104), @PROCESS_DATE)
					AND ISNULL(t.FIRST_REG, @PROCESS_DATE) = ISNULL(CONVERT(SMALLDATETIME, a.FIRST_REG, 104), @PROCESS_DATE)
					AND ISNULL(t.COMPLECT, '') = ISNULL(a.COMPLECT, '')
					AND ISNULL(t.COMMENT, '') = ISNULL(a.COMMENT, '')
			)

	/*
		Закинуть данные в активную таблицу
	*/

	IF @UPDATE = 1
	BEGIN
		INSERT INTO Task.Tasks(DATE, TIME, RECEIVER, ID_CLIENT, ID_STATUS, SHORT, NOTE, EXPIRE)
			SELECT dbo.DateOf(GETDATE()), NULL, NULL, ID_CLIENT, (SELECT ID FROM Task.TaskStatus WHERE PSEDO = N'ACTIVE'), 'Скидка', 'Изменился состав комплекта, проверьте правильность финансовых условий', NULL
			FROM
				(						
					SELECT DISTINCT ID_CLIENT
					FROM 
						dbo.ClientDistrView a WITH(NOEXPAND)						
						INNER JOIN dbo.SystemTable c ON a.HostID = c.HostID
						INNER JOIN #reg d ON d.SYS_NAME = c.SystemBaseName
										AND d.DISTR = a.DISTR
										AND d.COMP = a.COMP
						INNER JOIN dbo.RegNodeTable t ON d.SYS_NAME = t.SystemName
														AND d.DISTR = t.DistrNumber
														AND d.COMP = t.CompNumber
					WHERE 	(
								TECH_TYPE <> TechnolType
							OR	NET <> NetCount
							OR  t.ODON <> d.ODON
							OR	t.ODOFF <> d.ODOFF
							OR	d.SERVICE <> t.Service
							OR  SYS_NAME <> t.SystemName
							)
						AND EXISTS
							(
								SELECT *
								FROM dbo.DBFDistrView b 
								WHERE a.SystemBaseName = b.SYS_REG_NAME AND a.DISTR = b.DIS_NUM AND a.COMP = b.DIS_COMP_NUM
									AND (ISNULL(DF_FIXED_PRICE, 0) <> 0 OR ISNULL(DF_DISCOUNT, 0) <> 0)
							)
				) AS o_O
		
		DECLARE @EMSG NVARCHAR(MAX)
			
		SELECT @EMSG = 
			(			
				SELECT ISNULL(COMMENT, '') + ': ' + ISNULL(DISTR_STR, '') + CHAR(10)
				FROM
					(
						SELECT DISTINCT b.COMMENT, c.SystemShortName + ' ' + CONVERT(VARCHAR(20), DistrNumber) + 
							CASE CompNumber WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), CompNumber) END AS DISTR_STR
						FROM 
							#reg a
							INNER JOIN dbo.RegNodeTable b ON a.SYS_NAME = b.SystemName
															AND a.DISTR = b.DistrNumber
															AND a.COMP = b.CompNumber
							INNER JOIN dbo.SystemTable c ON b.SystemName = c.SystemBaseName
							INNER JOIN dbo.SystemTable d ON d.HostID = d.HostID
							INNER JOIN dbo.BLACK_LIST_REG e ON e.ID_SYS = d.SystemID AND e.DISTR = a.DISTR AND e.COMP = a.COMP
						WHERE e.P_DELETE = 0
							AND ISNULL(REG_DATE, '19910101') <> ISNULL(RegisterDate, '19910101')
					) AS y
				ORDER BY COMMENT, DISTR_STR FOR XML PATH('')
			)
			
		SELECT @EMSG = 'Был включен/зарегистрирован дистрибутив, внесенный в черный список ИнтернетПополнения: ' + CHAR(10) + @EMSG
			
		IF @EMSG IS NOT NULL
		BEGIN
			EXEC dbo.CLIENT_MESSAGE_SEND NULL, 1, 'Денисов', @EMSG, 0
			EXEC dbo.CLIENT_MESSAGE_SEND NULL, 1, 'boss', @EMSG, 0
		END
		
		IF EXISTS
			(
				SELECT *
				FROM #reg
				WHERE DIS_TYPE = 'NEK'
			)
		BEGIN
			DECLARE @MSG NVARCHAR(MAX)
			
			SELECT @MSG = 
				(			
					SELECT ISNULL(COMMENT, '') + ': ' + ISNULL(DISTR_STR, '') + CHAR(10)
					FROM
						(
							SELECT b.COMMENT, SystemShortName + ' ' + CONVERT(VARCHAR(20), DistrNumber) + 
								CASE CompNumber WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), CompNumber) END + ' (' + d.NT_SHORT + ')' AS DISTR_STR
							FROM 
								#reg a
								INNER JOIN dbo.RegNodeTable b ON a.SYS_NAME = b.SystemName
																AND a.DISTR = b.DistrNumber
																AND a.COMP = b.CompNumber
								INNER JOIN dbo.SystemTable c ON c.SystemBaseName = b.SystemName
								INNER JOIN Din.NetType d ON d.NT_NET = NET AND d.NT_TECH = TECH_TYPE AND NT_ODON = a.ODON AND NT_ODOFF = a.ODOFF
							WHERE DIS_TYPE = 'NEK'
								AND ISNULL(REG_DATE, '19910101') <> ISNULL(RegisterDate, '19910101')
						) AS y
					ORDER BY COMMENT, DISTR_STR FOR XML PATH('')
				)
				
			SELECT @MSG = 'Зарегистрированы ОДД: ' + CHAR(10) + @MSG
			
			IF @MSG IS NOT NULL
				EXEC dbo.CLIENT_MESSAGE_SEND NULL, 1, 'boss', @MSG, 0
		END
	
		DECLARE @CLIENT INT
	
		IF EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																	AND a.DISTR = b.DistrNumber
																	AND a.COMP = b.CompNumber
					INNER JOIN #reg c ON c.DISTR = b.DistrNumber AND c.COMP = b.CompNumber
					INNER JOIN dbo.SystemTable d ON c.SYS_NAME = d.SystemBaseName AND d.HostID = b.HostID
				WHERE c.SERVICE = 0 AND b.DS_REG <> 0 AND a.HostShort = 'К+'
			)
		BEGIN					
			IF (SELECT Maintenance.GlobalClientAutoClaim()) = 1
			BEGIN			
				DECLARE CL CURSOR LOCAL FOR 
					SELECT DISTINCT ID_CLIENT
					FROM dbo.ClientDistr
					WHERE ID IN
						(
							SELECT a.ID
							FROM 
								dbo.ClientDistrView a WITH(NOEXPAND)
								INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																				AND a.DISTR = b.DistrNumber
																				AND a.COMP = b.CompNumber
								INNER JOIN #reg c ON c.DISTR = b.DistrNumber AND c.COMP = b.CompNumber
								INNER JOIN dbo.SystemTable d ON c.SYS_NAME = d.SystemBaseName AND d.HostID = b.HostID
							WHERE c.SERVICE = 0 AND b.DS_REG <> 0 AND a.HostShort = 'К+'
						)
						
				OPEN CL
						
				
				
				FETCH NEXT FROM CL INTO @CLIENT
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO dbo.ClientStudyClaim(ID_CLIENT, DATE, NOTE, REPEAT, UPD_USER)
						SELECT @CLIENT, dbo.Dateof(GETDATE()), 'Восстановление', 0, 'Автомат'
						WHERE NOT EXISTS
							(
								SELECT *
								FROM dbo.ClientStudyClaim a
								WHERE ID_CLIENT = @CLIENT
									AND ID_MASTER IS NULL
									AND UPD_USER = 'Автомат'
							)
					
					EXEC dbo.CLIENT_REINDEX_CURRENT @CLIENT
				
					FETCH NEXT FROM CL INTO @CLIENT
				END				
				
				CLOSE CL
				DEALLOCATE CL
			END
							
		END		
	
		DELETE 
		FROM dbo.RegNodeTable
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #reg
				WHERE SYS_NAME = SystemName
					AND DISTR = DistrNumber
					AND COMP = CompNumber
			)

		UPDATE t
		SET t.DistrType = DIS_TYPE,
			t.TechnolType = TECH_TYPE,
			t.NetCount = NET,
			t.SubHost = r.SUBHOST,
			t.TransferCount = r.TRANS_COUNT,
			t.TransferLeft = r.TRANS_LEFT,
			t.Service = r.SERVICE,
			t.RegisterDate = r.REG_DATE,
			t.Comment = r.COMMENT,
			t.Complect = r.COMPLECT,
			t.OFFLINE = r.OFFLINE,
			t.Yubikey = r.Yubikey,
			t.KrfNeed = r.KRF,
			t.KrfDop = r.KRF1,
			t.AddParam = r.AddParam,
			t.ODON = r.ODON,
			t.ODOFF = r.ODOFF
		FROM dbo.RegNodeTable t
			INNER JOIN #reg r ON SystemName = SYS_NAME
							AND DistrNumber = DISTR
							AND CompNumber = COMP
		WHERE
			(
				DIS_TYPE <> DistrType
				OR	TECH_TYPE <> TechnolType
				OR	NET <> NetCount
				OR	r.SUBHOST <> t.SubHost
				OR	TRANS_COUNT <> TransferCount
				OR	TRANS_LEFT <> TransferLeft
				OR	r.SERVICE <> t.Service
				OR	ISNULL(REG_DATE, '19910101') <> ISNULL(RegisterDate, '19910101')
				OR	ISNULL(r.Comment, '') <> ISNULL(t.Comment, '')
				OR	ISNULL(r.Complect, '') <> ISNULL(t.Complect, '')
				OR	ISNULL(r.Offline, '') <> ISNULL(t.Offline, '')
				OR  ISNULL(t.Yubikey, '') = ISNULL(r.Yubikey, '')
				OR	ISNULL(t.KrfNeed, '') = ISNULL(r.KRF, '')
				OR	ISNULL(t.KrfDop, '') = ISNULL(r.KRF1, '')
				OR	ISNULL(t.AddParam, '') = ISNULL(r.AddParam, '')
				OR	ISNULL(t.ODON, '') = ISNULL(r.ODON, '')
				OR	ISNULL(t.ODOFF, '') = ISNULL(r.ODOFF, '')
			)

		INSERT INTO dbo.RegNodeTable(SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect, Offline, Yubikey, KrfNeed, KrfDop, AddParam, ODON, ODOFF)
			SELECT SYS_NAME, DISTR, COMP, DIS_TYPE, TECH_TYPE, NET, SUBHOST, TRANS_COUNT, TRANS_LEFT, SERVICE, REG_DATE, COMMENT, COMPLECT, OFFLINE, Yubikey, KRF, KRF1, AddParam, ODON, ODOFF
			FROM #reg a
			WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE SYS_NAME = SystemName
							AND DISTR = DistrNumber
							AND COMP = CompNumber
					)
					
		IF EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientDistrView a WITH(NOEXPAND)
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																	AND a.DISTR = b.DistrNumber
																	AND a.COMP = b.CompNumber
				WHERE a.DistrTypeID <> b.DistrTypeID OR a.SystemID <> b.SystemID
			)
		BEGIN
			INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
				SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
				FROM dbo.ClientDistr
				WHERE ID IN
					(
						SELECT a.ID
						FROM 
							dbo.ClientDistrView a WITH(NOEXPAND)
							INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																			AND a.DISTR = b.DistrNumber
																			AND a.COMP = b.CompNumber
						WHERE a.DistrTypeID <> b.DistrTypeID OR a.SystemID <> b.SystemID
					)
					
			IF (SELECT Maintenance.GlobalClientAutoClaim()) = 1
			BEGIN			
				DECLARE CL CURSOR LOCAL FOR 
					SELECT ID_CLIENT
					FROM dbo.ClientDistr
					WHERE ID IN
						(
							SELECT a.ID
							FROM 
								dbo.ClientDistrView a WITH(NOEXPAND)
								INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																				AND a.DISTR = b.DistrNumber
																				AND a.COMP = b.CompNumber
							WHERE a.DistrTypeID <> b.DistrTypeID OR a.SystemID <> b.SystemID
						)
						
				OPEN CL		
				
				FETCH NEXT FROM CL INTO @CLIENT
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO dbo.ClientStudyClaim(ID_CLIENT, DATE, NOTE, REPEAT, UPD_USER)
						SELECT @CLIENT, dbo.Dateof(GETDATE()), 'Замена дистрибутива', 0, 'Автомат'
						WHERE NOT EXISTS
							(
								SELECT *
								FROM dbo.ClientStudyClaim a
								WHERE ID_CLIENT = @CLIENT
									AND ID_MASTER IS NULL
									AND UPD_USER = 'Автомат'
							)
					
					EXEC dbo.CLIENT_REINDEX_CURRENT @CLIENT
				
					FETCH NEXT FROM CL INTO @CLIENT
				END				
				
				CLOSE CL
				DEALLOCATE CL
			END
					
			UPDATE a
			SET a.ID_SYSTEM	= ISNULL(b.ID_SYSTEM, a.ID_SYSTEM),
				a.ID_NET	= ISNULL(b.ID_NET, a.ID_NET),
				a.ON_DATE	= b.DATE,
				a.BDATE		= GETDATE(),
				a.UPD_USER	= ORIGINAL_LOGIN()
			FROM 
				dbo.ClientDistr a
				INNER JOIN
					(
						SELECT 
							a.ID, CONVERT(SMALLDATETIME, RegisterDate, 104) AS DATE, 
							CASE 
								WHEN a.DistrTypeID = b.DistrTypeID THEN NULL
								ELSE b.DistrTypeID
							END AS ID_NET,
							CASE
								WHEN a.SystemID = b.SystemID THEN NULL
								ELSE b.SystemID
							END AS ID_SYSTEM
						FROM 
							dbo.ClientDistrView a WITH(NOEXPAND)
							INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																			AND a.DISTR = b.DistrNumber
																			AND a.COMP = b.CompNumber
						WHERE a.DistrTypeID <> b.DistrTypeID OR a.SystemID <> b.SystemID
					) AS b ON a.ID = b.ID
			WHERE a.ID IN
				(
					SELECT a.ID
					FROM 
						dbo.ClientDistrView a WITH(NOEXPAND)
						INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID
																		AND a.DISTR = b.DistrNumber
																		AND a.COMP = b.CompNumber
					WHERE a.DistrTypeID <> b.DistrTypeID OR a.SystemID <> b.SystemID
				)			
		END		
	END	

	IF OBJECT_ID('tempdb..#reg') IS NOT NULL
		DROP TABLE #reg
END