USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DATA_INTERVAL_SELECT]
	@SCHEMA	NVARCHAR(128),
	@TABLE	NVARCHAR(128),
	@PERIOD	NVARCHAR(128),
	@TYPE	NVARCHAR(128),
	@VALUE	NVARCHAR(128),
	@TYPEID	INT,
	@DEPAND	VARCHAR(50)
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

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		CREATE TABLE #tmp
			(
				TYPEID	SMALLINT,
				PERIOD	SMALLINT,
				VAL		DECIMAL(8, 4),
				DEPAND	VARCHAR(50)
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'
		INSERT INTO #tmp(TYPEID, PERIOD, VAL, DEPAND)
			SELECT ' + @TYPE + ', ' + @PERIOD + ', ' + @VALUE + ', LEFT(' + ISNULL(@DEPAND, 'NULL') + ', 50)
			FROM ' + @SCHEMA + '.' + @TABLE + '
			WHERE ' + @TYPE + ' = ' + CONVERT(VARCHAR(20), @TYPEID)


		EXEC (@SQL)


		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID		SMALLINT IDENTITY(1, 1),
				DEPAND	VARCHAR(50),
				RCOEF	DECIMAL(8, 4),
				RBEGIN	SMALLINT,
				REND	SMALLINT
			)

		DECLARE @ID	SMALLINT

		INSERT INTO #res(DEPAND, RCOEF, RBEGIN, REND)
			SELECT TOP 1 DEPAND, VAL, PR_ID, NULL
			FROM
				#tmp
				INNER JOIN dbo.PeriodTable ON PR_ID = PERIOD
			ORDER BY PR_DATE

		SELECT @ID = SCOPE_IDENTITY()

		DECLARE @PR_ID	SMALLINT

		SELECT @PR_ID = RBEGIN
		FROM #res

		WHILE @PR_ID IS NOT NULL
		BEGIN
			SET @PR_ID = dbo.PERIOD_NEXT(@PR_ID)

			IF
				(
					SELECT RCOEF
					FROM #res
					WHERE ID = @ID
				) <>
				(
					SELECT VAL
					FROM #tmp
					WHERE PERIOD = @PR_ID
				)
			BEGIN
				UPDATE #res
				SET REND = dbo.PERIOD_PREV(@PR_ID)
				WHERE ID = @ID

				INSERT INTO #res(DEPAND, RCOEF, RBEGIN, REND)
					SELECT DEPAND, VAL, PERIOD, NULL
					FROM #tmp
					WHERE PERIOD = @PR_ID

				SELECT @ID = SCOPE_IDENTITY()
			END
		END

		UPDATE #res
		SET REND =
			(
				SELECT PR_ID
				FROM dbo.PeriodTable
				WHERE PR_DATE =
					(
						SELECT MAX(PR_DATE)
						FROM
							dbo.PeriodTable
							INNER JOIN #TMP ON PERIOD = PR_ID
					)
			)
		WHERE ID = @ID

		SELECT
			DEPAND, RCOEF,
			CASE
				WHEN a.PR_NAME = b.PR_NAME THEN a.PR_NAME
				ELSE 'с ' + a.PR_NAME + ' по ' + b.PR_NAME
			END AS RINTERVAL
		FROM
			#res
			INNER JOIN dbo.PeriodTable a ON a.PR_ID = RBEGIN
			INNER JOIN dbo.PeriodTable b ON b.PR_ID = REND
		ORDER BY a.PR_DATE


		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DATA_INTERVAL_SELECT] TO public;
GO
