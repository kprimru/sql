USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[USERLOG_LOAD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[USERLOG_LOAD]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[USERLOG_LOAD]
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

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				RW NVARCHAR(1024)
			)

		EXEC xp_cmdshell 'xcopy \\bim\vol2\veda3000\cons\adm\userlog.txt c:\data\userlog\*.* /y /d /s', no_output

		BULK INSERT #temp FROM 'c:\data\userlog\userlog.txt' WITH (CODEPAGE=1251)

		ALTER TABLE #temp ADD ID INT IDENTITY(1, 1)

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID		INT PRIMARY KEY,
				DATA	NVARCHAR(MAX),
				USR		NVARCHAR(128),
				COMP	NVARCHAR(128),
				OPER	NVARCHAR(128),
				DT		NVARCHAR(128),
				TM		NVARCHAR(128),
				A1		NVARCHAR(128),
				A2		NVARCHAR(128)
			)

		INSERT INTO #res(ID, DATA)
			SELECT ID, RW
			FROM #temp

		UPDATE #res
		SET USR = LEFT(DATA, CHARINDEX(' ', DATA) - 1)

		UPDATE #res
		SET DATA = RIGHT(DATA, LEN(DATA) - CHARINDEX(' ', DATA))

		UPDATE #res
		SET COMP = LEFT(DATA, CHARINDEX(' ', DATA) - 1)

		UPDATE #res
		SET DATA = RIGHT(DATA, LEN(DATA) - CHARINDEX(' ', DATA))

		UPDATE #res
		SET OPER = LEFT(DATA, CHARINDEX(' ', DATA) - 1)

		UPDATE #res
		SET DATA = RIGHT(DATA, LEN(DATA) - CHARINDEX(' ', DATA))

		UPDATE #res
		SET DT = LEFT(DATA, CHARINDEX(' ', DATA) - 1)

		UPDATE #res
		SET DATA = RIGHT(DATA, LEN(DATA) - CHARINDEX(' ', DATA))

		UPDATE #res
		SET TM = LEFT(DATA, CHARINDEX(' ', DATA) - 1)

		UPDATE #res
		SET DATA = RIGHT(DATA, LEN(DATA) - CHARINDEX(' ', DATA))

		UPDATE #res
		SET DATA = LTRIM(RTRIM(REPLACE(DATA, 'пользователем', '')))

		UPDATE #res
		SET A1 = LEFT(DATA, CHARINDEX(' ', DATA) - 1)
		WHERE OPER = 'Зашел' AND CHARINDEX(' ', DATA) > 0


		UPDATE #res
		SET DATA = RIGHT(DATA, LEN(DATA) - CHARINDEX(' ', DATA))
		WHERE CHARINDEX(' ', DATA) > 0

		UPDATE #res
		SET A2 = DATA

		INSERT INTO Maintenance.UserLog(USR, COMP, OPER, DT, A1, A2)
			SELECT USR, COMP, OPER, DT, A1, A2
			FROM
				(
					SELECT
						USR, COMP, OPER,
						CONVERT(DATETIME, LEFT(CONVERT(NVARCHAR(64), CONVERT(DATETIME, DT, 104), 120), 10) + ' ' + TM, 120) AS DT,
						A1, A2
					FROM #res
				) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Maintenance.UserLog b
					WHERE a.USR = b.USR AND a.COMP = b.COMP AND a.OPER = b.OPER AND a.DT = b.DT
				)

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
