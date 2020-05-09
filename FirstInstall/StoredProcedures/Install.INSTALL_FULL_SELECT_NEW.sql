USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_FULL_SELECT_NEW]
	@BDATE		SMALLDATETIME	= NULL,
	@EDATE		SMALLDATETIME	= NULL,
	@CLIENT		VARCHAR(50)		= NULL,
	@NODISTR	BIT				= NULL,
	@NOCLAIM	BIT				= NULL,
	@NOINSTALL	BIT				= NULL,
	@NOACT		BIT				= NULL,
	@RC			INT				= NULL OUTPUT,
	@DISTR		VARCHAR(20)		= NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#install') IS NOT NULL
		DROP TABLE #install

	CREATE TABLE #install
		(
			IND_ID	UNIQUEIDENTIFIER PRIMARY KEY
		)

	IF @BDATE IS NOT NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE INS_DATE >= @BDATE
	ELSE IF @EDATE IS NOT NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE INS_DATE <= @EDATE
	ELSE IF @CLIENT IS NOT NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE CL_NAME LIKE @CLIENT
	ELSE IF @NODISTR IS NOT NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE (IND_DISTR IS NULL OR (LTRIM(RTRIM(IND_DISTR)) = ''''))
	ELSE IF @NOCLAIM	IS NOT NULL AND @NODISTR IS NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE IND_CLAIM IS NULL
	ELSE IF @NOINSTALL IS NOT NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE IND_INSTALL_DATE IS NULL
	ELSE IF @DISTR IS NOT NULL
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView
			WHERE IND_DISTR LIKE @DISTR + '%'
	ELSE
		INSERT INTO #install(IND_ID)
			SELECT IND_ID
			FROM Install.InstallFullView

	IF @BDATE IS NOT NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE INS_DATE >= @BDATE
			)

	IF @EDATE IS NOT NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE INS_DATE <= @EDATE
			)

	IF @CLIENT IS NOT NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE CL_NAME LIKE @CLIENT
			)

	IF @NODISTR IS NOT NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE (IND_DISTR IS NULL OR (LTRIM(RTRIM(IND_DISTR)) = ''''))
			)

	IF @NOCLAIM	IS NOT NULL AND @NODISTR IS NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE IND_CLAIM IS NULL
			)

	IF @NOINSTALL IS NOT NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE IND_INSTALL_DATE IS NULL
			)

	IF @DISTR IS NOT NULL
		DELETE
		FROM #install
		WHERE IND_ID NOT IN
			(
				SELECT IND_ID
				FROM Install.InstallFullView
				WHERE IND_DISTR LIKE @DISTR + '%'
			)


	SELECT
		b.IND_ID AS ID, INS_ID AS ID_MASTER,
		INS_ID, b.IND_ID, --INS_DATE,
		IN_DATE, ID_FULL_PAY,
		CL_ID_MASTER, CL_NAME,
		VD_ID_MASTER, VD_NAME,
		ID_COMMENT,
		SYS_ID_MASTER, SYS_SHORT,
		DT_ID_MASTER, DT_SHORT AS DT_NAME,
		NT_ID_MASTER, --NT_NAME,
		TT_ID_MASTER, --TT_NAME,
		NT_NEW_NAME,
		IND_DISTR,
		PER_ID_MASTER, PER_NAME AS IND_PERSONAL, --PER_NAME,
		IND_INSTALL_DATE, IND_ARCHIVE,
		IND_CONTRACT, CLM_ID, CLM_DATE, IND_CLAIM,
		IND_ACT_DATE, IND_ACT_RETURN, IND_LOCK, IND_COMMENTS,
		IND_COMMENTS AS IND_COMMENTS_STR, ID_RESTORE, ID_EXCHANGE, ID_LOCK,
		IA_ID_MASTER, IA_NAME, IA_NORM, IND_ACT_NOTE,
		CONVERT(NVARCHAR(512), IND_TO_NUM) As IND_TO_NUM, IND_LIMIT, ID_PERSONAL
	FROM
		#install a
		INNER JOIN Install.InstallFullView b ON a.IND_ID = b.IND_ID

	UNION ALL

	SELECT DISTINCT
		INS_ID AS ID, NULL AS ID_MASTER,
		INS_ID, NULL, --INS_DATE,
		IN_DATE,
			(
				SELECT TOP 1 ID_FULL_PAY
				FROM
					#install z
					INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
				WHERE y.INS_ID = b.INS_ID
				ORDER BY ID_FULL_PAY
			),
		CL_ID_MASTER, CL_NAME,
		VD_ID_MASTER, VD_NAME,
		REVERSE(STUFF(REVERSE(
			(
				SELECT ID_COMMENT + ','
				FROM
					(
						SELECT DISTINCT ID_COMMENT
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
						WHERE y.INS_ID = b.INS_ID
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, '')),
		NULL,
		REVERSE(STUFF(REVERSE(
			(
				SELECT SYS_SHORT + ','
				FROM
					(
						SELECT DISTINCT y.SYS_SHORT, SYS_ORDER
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
						WHERE y.INS_ID = b.INS_ID
					) AS o_O
				ORDER BY SYS_ORDER FOR XML PATH('')
			)), 1, 1, '')),
		NULL,
		REVERSE(STUFF(REVERSE(
			(
				SELECT DT_SHORT + ','
				FROM
					(
						SELECT DISTINCT y.DT_SHORT
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
						WHERE y.INS_ID = b.INS_ID
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, '')),
		NULL, --NT_NAME,
		NULL, --TT_NAME,
		REVERSE(STUFF(REVERSE(
			(
				SELECT NT_NEW_NAME + ','
				FROM
					(
						SELECT DISTINCT y.NT_NEW_NAME
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
						WHERE y.INS_ID = b.INS_ID
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, '')),
		NULL,
		NULL,
		REVERSE(STUFF(REVERSE(
			(
				SELECT PER_NAME + ','
				FROM
					(
						SELECT DISTINCT y.PER_NAME
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
						WHERE y.INS_ID = b.INS_ID
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, '')),
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND IND_INSTALL_DATE IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MAX(IND_INSTALL_DATE)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND IND_INSTALL_DATE IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MAX(IND_ARCHIVE)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND IND_CONTRACT IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MAX(IND_CONTRACT)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END,
		NULL,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND CLM_DATE IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MAX(CLM_DATE)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END, NULL,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND IND_ACT_DATE IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MAX(IND_ACT_DATE)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END,
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND IND_ACT_RETURN IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MAX(IND_ACT_RETURN)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END,
		NULL, NULL,
		NULL, NULL, NULL, NULL,
		NULL, NULL, NULL,
				(
					SELECT TOP 1 IND_ACT_NOTE
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
					ORDER BY LEN(IND_ACT_NOTE) DESC
				),
		REVERSE(STUFF(REVERSE(
			(
				SELECT CONVERT(NVARCHAR(16), IND_TO_NUM) + ','
				FROM
					(
						SELECT DISTINCT IND_TO_NUM
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
						WHERE y.INS_ID = b.INS_ID AND IND_TO_NUM IS NOT NULL
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, '')),
		CASE
			WHEN EXISTS
				(
					SELECT *
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID AND IND_LIMIT IS NULL
				) THEN NULL
			ELSE
				(
					SELECT MIN(IND_LIMIT)
					FROM
						#install z
						INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
					WHERE y.INS_ID = b.INS_ID
				)
		END,
		REVERSE(STUFF(REVERSE(
			(
				SELECT CONVERT(NVARCHAR(16), ID_PERSONAL) + ','
				FROM
					(
						SELECT DISTINCT ID_PERSONAL
						FROM
							#install z
							INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
							--INNER JOIN Distr.SystemDetail x ON x.SYS_ID_MASTER = y.SYS_ID_MASTER
						WHERE y.INS_ID = b.INS_ID AND ID_PERSONAL IS NOT NULL
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, ''))
	FROM
		#install a
		INNER JOIN Install.InstallFullView b ON a.IND_ID = b.IND_ID
	WHERE
		(
			SELECT COUNT(z.IND_ID)
			FROM
				#install z
				INNER JOIN Install.InstallFullView y ON z.IND_ID = y.IND_ID
			WHERE y.INS_ID = b.INS_ID
		) > 1


	ORDER BY IN_DATE, CL_NAME, VD_NAME, SYS_SHORT

	IF OBJECT_ID('tempdb..#install') IS NOT NULL
		DROP TABLE #install

	/*
	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = '
	SELECT
		INS_ID, IND_ID, --INS_DATE,
		IN_DATE, ID_FULL_PAY,
		CL_ID_MASTER, CL_NAME,
		VD_ID_MASTER, VD_NAME,
		ID_COMMENT,
		SYS_ID_MASTER, SYS_SHORT,
		DT_ID_MASTER, DT_SHORT AS DT_NAME,
		NT_ID_MASTER, --NT_NAME,
		TT_ID_MASTER, --TT_NAME,
		NT_NEW_NAME,
		IND_DISTR,
		PER_ID_MASTER, PER_NAME,
		IND_INSTALL_DATE,
		IND_CONTRACT, CLM_ID, CLM_DATE, IND_CLAIM,
		IND_ACT_DATE, IND_ACT_RETURN, IND_LOCK, IND_COMMENTS,
		IND_COMMENTS AS IND_COMMENTS_STR, ID_RESTORE, ID_EXCHANGE, ID_LOCK,
		IA_ID_MASTER, IA_NAME, IA_NORM
	FROM Install.InstallFullView
	WHERE 1 = 1 '

	IF @BDATE IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND INS_DATE >= @BDATE '
	END

	IF @EDATE IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND INS_DATE <= @EDATE '
	END

	IF @CLIENT IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND CL_NAME LIKE @CLIENT '
	END

	IF @NODISTR	IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND (IND_DISTR IS NULL OR (LTRIM(RTRIM(IND_DISTR)) = '''')) '
	END

	IF @NOCLAIM	IS NOT NULL AND @NODISTR IS NULL
	BEGIN
		SET @SQL = @SQL + ' AND IND_CLAIM IS NULL '
	END

	IF @NOINSTALL IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND IND_INSTALL_DATE IS NULL '
	END

	IF @NOACT IS NOT NULL
	BEGIN
		SET @SQL = @SQL + ' AND IND_ACT_RETURN IS NULL '
	END

	IF @DISTR IS NOT NULL
		SET @SQL = @SQL + ' AND IND_DISTR LIKE @DISTR '

	EXEC sp_executesql @SQL, N'
		@BDATE		SMALLDATETIME,
		@EDATE		SMALLDATETIME,
		@CLIENT		VARCHAR(50),
		@DISTR		VARCHAR(20)',
		@BDATE, @EDATE, @CLIENT, @DISTR
	*/

	SELECT @RC = @@ROWCOUNT
END



GO
GRANT EXECUTE ON [Install].[INSTALL_FULL_SELECT_NEW] TO rl_install_r;
GO