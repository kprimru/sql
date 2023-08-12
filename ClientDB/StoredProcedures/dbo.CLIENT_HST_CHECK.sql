USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_HST_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_HST_CHECK]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_HST_CHECK]
	@LIST NVARCHAR(MAX)
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

		DECLARE @XML XML

		SET @XML = CAST(@LIST AS XML)

		IF OBJECT_ID('tempdb..#hst') IS NOT NULL
			DROP TABLE #hst

		CREATE TABLE #hst
			(
				FILE_PATH	NVARCHAR(512),
				FILE_SIZE	BIGINT,
				FILE_DATE	DATETIME,
				FILE_MD5	NVARCHAR(128),
				STT_NAME	NVARCHAR(128),
				STT_TMP		NVARCHAR(128),
				NUM			INT,
				DISTR		INT,
				COMP		TINYINT,
				ID_CLIENT	INT,
				ERR_TYPE	TINYINT,
				NOTE		NVARCHAR(MAX),
				ENBL		BIT
			)

		INSERT INTO #hst(FILE_PATH, FILE_SIZE, FILE_DATE, FILE_MD5, STT_NAME, ERR_TYPE, ENBL)
			SELECT
				c.value('(../@file)', 'NVARCHAR(512)'),
				c.value('(../@size)', 'BIGINT'),
				CONVERT(DATETIME, c.value('(../@date)', 'NVARCHAR(64)'), 120),
				c.value('(../@md5)', 'NVARCHAR(128)'),
				c.value('(@file)', 'NVARCHAR(128)'),
				0, 1
			FROM
				@xml.nodes('/root/item/*') AS a(c)

		UPDATE #hst
		SET STT_TMP = STT_NAME
		WHERE STT_NAME IS NOT NULL

		UPDATE #hst
		SET NUM = CONVERT(INT, LEFT(STT_TMP, CHARINDEX('_', STT_TMP) - 1))
		WHERE STT_NAME IS NOT NULL

		UPDATE #hst
		SET STT_TMP = RIGHT(STT_TMP, LEN(STT_TMP) - LEN(NUM) - 1)
		WHERE STT_NAME IS NOT NULL

		UPDATE #hst
		SET DISTR = CONVERT(INT, LEFT(STT_TMP, CHARINDEX('_', STT_TMP) - 1))
		WHERE STT_NAME IS NOT NULL

		UPDATE #hst
		SET STT_TMP = RIGHT(STT_TMP, LEN(STT_TMP) - /*LEN(DISTR)*/6 - 1)
		WHERE STT_NAME IS NOT NULL

		UPDATE #hst
		SET STT_TMP = RIGHT(STT_TMP, LEN(STT_TMP) - 1)
		WHERE STT_TMP LIKE '[_]%'

		UPDATE #hst
		SET COMP =
			CASE
				WHEN CHARINDEX('_', STT_TMP) <= 3 AND CHARINDEX('_', STT_TMP) <> 0 THEN CONVERT(TINYINT, LEFT(STT_TMP, CHARINDEX('_', STT_TMP) - 1))
				ELSE 1
			END
		WHERE STT_NAME IS NOT NULL

		UPDATE #hst
		SET ID_CLIENT =
				(
					SELECT TOP 1 ID_CLIENT
					FROM dbo.ClientDistrView b WITH(NOEXPAND)
					WHERE a.DISTR = b.DISTR
						AND a.COMP = b.COMP
						AND c.HostID = b.HostID
						AND DS_REG = 0
					ORDER BY DS_REG, SystemOrder
				)
		FROM
			#hst a
			INNER JOIN dbo.SystemTable c ON c.SystemNumber = a.NUM

		UPDATE #hst
		SET ID_CLIENT =
				(
					SELECT TOP 1 ID_CLIENT
					FROM dbo.ClientDistrView b WITH(NOEXPAND)
					WHERE a.DISTR = b.DISTR
						AND a.COMP = b.COMP
						AND c.HostID = b.HostID
					ORDER BY DS_REG, SystemOrder
				)
		FROM
			#hst a
			INNER JOIN dbo.SystemTable c ON c.SystemNumber = a.NUM
		WHERE a.ID_CLIENT IS NULL

		UPDATE a
		SET NOTE = 'Неоднозначный клиент',
			ERR_TYPE = 1,
			ENBL = 0
		FROM
			#hst a
			INNER JOIN
				(
					SELECT FILE_PATH, COUNT(DISTINCT ID_CLIENT) AS CNT
					FROM #hst
					WHERE ID_CLIENT IS NOT NULL
					GROUP BY FILE_PATH
					HAVING COUNT(DISTINCT ID_CLIENT) > 1
				) AS b ON a.FILE_PATH = b.FILE_PATH

		UPDATE #hst
		SET NOTE = ISNULL(NOTE + ', ', '') + 'Не удалось идентифицировать клиента',
			ERR_TYPE = 3,
			ENBL = 0
		WHERE ID_CLIENT IS NULL

		UPDATE a
		SET NOTE = ISNULL(NOTE + ', ', '') + 'Попытка загрузки одинакового файла',
			ERR_TYPE = 4,
			ENBL = 0
		FROM
			#hst a
			INNER JOIN
				(
					SELECT FILE_SIZE, FILE_DATE, FILE_MD5
					FROM #hst b
					GROUP BY FILE_SIZE, FILE_DATE, FILE_MD5
					HAVING COUNT(DISTINCT FILE_PATH) > 1 AND COUNT(DISTINCT ID_CLIENT) > 1
				) AS b ON a.FILE_SIZE = b.FILE_SIZE AND a.FILE_DATE = b.FILE_DATE AND a.FILE_MD5 = b.FILE_MD5

		/*
		UPDATE a
		SET NOTE = ISNULL(NOTE + ', ', '') + 'Данный файл уже был загружен в папке "' + b.PATH + '" ' + CONVERT(NVARCHAR(32), b.PROCESS_DATE, 104),
			ERR_TYPE = 2,
			ENBL = 0
		FROM
			#hst a
			INNER JOIN dbo.ClientHST b ON a.FILE_SIZE = b.FILE_SIZE AND a.FILE_DATE = b.FILE_DATE AND a.FILE_MD5 = b.FILE_MD5
		*/

		DELETE a
		FROM #hst a
		WHERE EXISTS
			(
				SELECT *
				FROM dbo.ClientHST b
				WHERE a.FILE_SIZE = b.FILE_SIZE AND a.FILE_DATE = b.FILE_DATE AND a.FILE_MD5 = b.FILE_MD5
			)


		SELECT DISTINCT
			a.ID_CLIENT, a.FILE_PATH, a.FILE_SIZE, a.FILE_DATE, a.FILE_MD5,
			a.NOTE, a.ENBL, ClientFullName, ServiceName, CONVERT(INT, NULL) AS HIS_COUNT
		FROM
			#hst a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
		WHERE ERR_TYPE = 0

		UNION ALL

		SELECT DISTINCT NULL,
				a.FILE_PATH, a.FILE_SIZE, a.FILE_DATE, a.FILE_MD5,
				a.NOTE +
					REVERSE(STUFF(REVERSE((
						SELECT ClientFullName + '(' + ServiceName + ' / ' + STT_NAME + '), '
						FROM
							(
								SELECT DISTINCT ClientFullName, ServiceName, STT_NAME
								FROM
									#hst b
									INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
								WHERE b.FILE_PATH = a.FILE_PATH
							) AS o_O
						ORDER BY ClientFullname FOR XML PATH('')
					)), 1, 2, '')),
				a.ENBL, NULL, NULL, CONVERT(INT, NULL) AS HIS_COUNT
		FROM
			#hst a
		WHERE ERR_TYPE = 1

		UNION ALL

		SELECT DISTINCT
			a.ID_CLIENT, a.FILE_PATH, a.FILE_SIZE, a.FILE_DATE, a.FILE_MD5,
			a.NOTE, a.ENBL, ClientFullName, ServiceName, CONVERT(INT, NULL) AS HIS_COUNT
		FROM
			#hst a
			LEFT OUTER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
		WHERE ERR_TYPE = 4

		UNION ALL

		SELECT DISTINCT NULL,
				a.FILE_PATH, a.FILE_SIZE, a.FILE_DATE, a.FILE_MD5,
				a.NOTE + ' ' +
					REVERSE(STUFF(REVERSE((
						SELECT STT_NAME + '(' + CONVERT(VARCHAR(20), NUM) + '_' + CONVERT(VARCHAR(20), DISTR) + '_' + CONVERT(VARCHAR(20), COMP) + '), '
						FROM
							(
								SELECT DISTINCT STT_NAME
								FROM
									#hst b
								WHERE b.FILE_PATH = a.FILE_PATH
							) AS o_O
						ORDER BY STT_NAME FOR XML PATH('')
					)), 1, 2, '')),
				a.ENBL, NULL, NULL, CONVERT(INT, NULL) AS HIS_COUNT
		FROM
			#hst a
		WHERE ERR_TYPE = 3

		UNION ALL

		SELECT ID_CLIENT, FILE_PATH, FILE_SIZE, FILE_DATE, FILE_MD5, NOTE, CONVERT(BIT, CASE RN WHEN 1 THEN 1 ELSE 0 END),
			ClientFullName, ServiceName, HIS_COUNT
		FROM
			(
				SELECT
					ID_CLIENT, FILE_PATH, FILE_SIZE, FILE_DATE, FILE_MD5, NOTE, ENBL,
					ClientFullName, ServiceName, HIS_COUNT, ROW_NUMBER() OVER(PARTITION BY FILE_SIZE, FILE_DATE, FILE_MD5 ORDER BY FILE_PATH) AS RN
				FROM
					(
						SELECT DISTINCT
							a.ID_CLIENT, a.FILE_PATH, a.FILE_SIZE, a.FILE_DATE, a.FILE_MD5, a.NOTE + '(' + a.FILE_MD5 + ')' AS NOTE, a.ENBL,
							ClientFullName, ServiceName, CONVERT(INT, NULL) AS HIS_COUNT
						FROM
							#hst a
							LEFT OUTER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ID_CLIENT = b.ClientID
						WHERE ERR_TYPE = 4
					) AS o_O
			) AS o_O
		WHERE RN = 1

		ORDER BY ClientFullName, FILE_PATH, FILE_MD5

		IF OBJECT_ID('tempdb..#hst') IS NOT NULL
			DROP TABLE #hst

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_HST_CHECK] TO rl_hst_process;
GO
