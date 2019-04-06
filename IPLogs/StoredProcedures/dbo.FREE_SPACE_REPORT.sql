USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FREE_SPACE_REPORT]
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr

	CREATE TABLE #distr
		(
			SYS		SMALLINT,
			DISTR	INT,
			COMP	TINYINT
		)	

	INSERT INTO #distr(SYS, DISTR, COMP)
		SELECT DISTINCT CSD_SYS, CSD_DISTR, CSD_COMP
		FROM dbo.ClientStatDetail a
		WHERE CSD_START >= DATEADD(MONTH, -1, GETDATE())		

	IF OBJECT_ID('tempdb..#distr_code') IS NOT NULL
		DROP TABLE #distr_code

	CREATE TABLE #distr_code
		(
			SYS		SMALLINT,
			DISTR	INT,
			COMP	TINYINT,
			NUM		BIGINT,
			CODE	SMALLINT
		)
		
	INSERT INTO #distr_code(SYS, DISTR, COMP, NUM, CODE)
		SELECT SYS, DISTR, COMP, 
			(
				SELECT TOP 1 CSD_NUM
				FROM dbo.ClientStatDetail a
				WHERE a.CSD_SYS = b.SYS AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
				ORDER BY CSD_START DESC
			),
			(
				SELECT TOP 1 CSD_CODE_CLIENT
				FROM dbo.ClientStatDetail a
				WHERE a.CSD_SYS = b.SYS AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
				ORDER BY CSD_START DESC
			) 
		FROM #distr b
		
	INSERT INTO #distr_code(SYS, DISTR, COMP, NUM, CODE)
		SELECT SYS, DISTR, COMP, 
			(
				SELECT TOP 1 CSD_NUM
				FROM dbo.ClientStatDetail a
				WHERE a.CSD_SYS = b.SYS AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
					AND a.CSD_NUM NOT IN
						(
							SELECT CSD_NUM
							FROM #distr_code c
							WHERE a.CSD_SYS = c.SYS AND a.CSD_DISTR = c.DISTR AND a.CSD_COMP = c.COMP AND a.CSD_NUM = c.NUM
						)
				ORDER BY CSD_START DESC
			),
			(
				SELECT TOP 1 CSD_CODE_CLIENT
				FROM dbo.ClientStatDetail a
				WHERE a.CSD_SYS = b.SYS AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
					AND a.CSD_NUM NOT IN
						(
							SELECT CSD_NUM
							FROM #distr_code c
							WHERE a.CSD_SYS = c.SYS AND a.CSD_DISTR = c.DISTR AND a.CSD_COMP = c.COMP AND a.CSD_NUM = c.NUM
						)
				ORDER BY CSD_START DESC
			) 
		FROM #distr b
		
	INSERT INTO #distr_code(SYS, DISTR, COMP, NUM, CODE)
		SELECT SYS, DISTR, COMP, 
			(
				SELECT TOP 1 CSD_NUM
				FROM dbo.ClientStatDetail a
				WHERE a.CSD_SYS = b.SYS AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
					AND a.CSD_NUM NOT IN
						(
							SELECT CSD_NUM
							FROM #distr_code c
							WHERE a.CSD_SYS = c.SYS AND a.CSD_DISTR = c.DISTR AND a.CSD_COMP = c.COMP AND a.CSD_NUM = c.NUM
						)
				ORDER BY CSD_START DESC
			),
			(
				SELECT TOP 1 CSD_CODE_CLIENT
				FROM dbo.ClientStatDetail a
				WHERE a.CSD_SYS = b.SYS AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
					AND a.CSD_NUM NOT IN
						(
							SELECT CSD_NUM
							FROM #distr_code c
							WHERE a.CSD_SYS = c.SYS AND a.CSD_DISTR = c.DISTR AND a.CSD_COMP = c.COMP AND a.CSD_NUM = c.NUM
						)
				ORDER BY CSD_START DESC
			) 
		FROM #distr b

	DELETE a
	FROM #distr a
	WHERE NOT EXISTS
		(
			SELECT *
			FROM
				(
					SELECT SYS, DISTR, COMP
					FROM #distr a
					WHERE (SELECT COUNT(*) FROM #distr_code b WHERE a.SYS = b.SYS AND a.DISTR = b.DISTR AND a.COMP = b.COMP) = 3
						AND (SELECT COUNT(*) FROM #distr_code b WHERE a.SYS = b.SYS AND a.DISTR = b.DISTR AND a.COMP = b.COMP AND CODE = 3) = 3
				) AS b
			WHERE a.SYS = b.SYS AND a.DISTR = b.DISTR AND a.COMP = b.COMP
		)

	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res

	CREATE TABLE #res
		(
			DISTR	NVARCHAR(128),
			EMAIL	NVARCHAR(128),
			NAME	NVARCHAR(256),
			CLIENT	NVARCHAR(512),
			NOTE	NVARCHAR(MAX)
		)

	INSERT INTO #res(DISTR, EMAIL, NAME, CLIENT, NOTE)
		SELECT 
			DistrStr, ManagerEmail, ManagerFullName, ClientFullName,
			(
				SELECT TOP 1 'На ' + CONVERT(VARCHAR(20), UF_DATE, 104) + ': загрузочный диск - ' + dbo.FileSizeToStr(UF_BOOT_FREE * 1024 * 1024) + ', диск с К+ - ' + dbo.FileSizeToStr(UF_CONS_FREE * 1024 * 1024)
				FROM 
					[PC275-SQL\ALPHA].ClientDB.USR.USRComplectNumberView z
					INNER JOIN [PC275-SQL\ALPHA].ClientDB.USR.USRFile y ON z.UD_ID = y.UF_ID_COMPLECT
				WHERE z.UD_SYS = a.SYS AND z.UD_DISTR = a.DISTR AND z.UD_COMP = a.COMP AND y.UF_ACTIVE = 1
				ORDER BY UF_DATE DESC
			)
		FROM 
			#distr a
			INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable b ON b.SystemNumber =  a.SYS
			INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = b.SystemID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
			INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ClientView d WITH(NOEXPAND) ON c.ID_CLIENT = d.ClientID
			INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ManagerTable e ON e.ManagerID = d.ManagerID
		WHERE DS_REG = 0

	DECLARE E CURSOR LOCAL FOR 
		SELECT DISTINCT EMAIL
		FROM #res
		WHERE ISNULL(EMAIL, '') <> ''

	OPEN E

	DECLARE @ML NVARCHAR(128)
	DECLARE @BODY	NVARCHAR(MAX)

	FETCH NEXT FROM E INTO @ML

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @BODY =
			(
				SELECT CLIENT + ' (' + DISTR + ')' + CHAR(10) + NOTE + CHAR(10) + CHAR(10)
				FROM #res
				WHERE EMAIL = @ML
				ORDER BY CLIENT FOR XML PATH('')
			)
		
		SET @BODY = N'У данных клиентов по меньшей мере 3 последних пополнения закончились с кодом 3 (отсутствует место или диск неисправен).' + CHAR(10) + CHAR(10) + @BODY
		
		EXEC msdb.dbo.sp_send_dbmail 
					@profile_name	=	'SQLMail',
					@recipients		=	@ML,
					@blind_copy_recipients = 'denisov@bazis;blohin@bazis;bateneva@bazis',
					@body			=	@BODY,
					@subject		=	'Проблемы с ИП пополнением',
					@query_result_header	=	0				

		FETCH NEXT FROM E INTO @ML
	END

	CLOSE E
	DEALLOCATE E

	IF OBJECT_ID('tempdb..#res') IS NOT NULL
		DROP TABLE #res

	IF OBJECT_ID('tempdb..#distr_code') IS NOT NULL
		DROP TABLE #distr_code

	IF OBJECT_ID('tempdb..#distr') IS NOT NULL
		DROP TABLE #distr
END
