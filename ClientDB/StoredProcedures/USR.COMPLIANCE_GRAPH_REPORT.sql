USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[COMPLIANCE_GRAPH_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@PER_AVG	DECIMAL(8, 4) = NULL OUTPUT,
	@PER_MIN	DECIMAL(8, 4) = NULL OUTPUT
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

		DECLARE @WEEK TABLE
			(
				WEEK_ID	INT IDENTITY(1, 1),
				WBEGIN SMALLDATETIME,
				WEND SMALLDATETIME
			)

		DECLARE @TBEGIN SMALLDATETIME
		DECLARE @TEND SMALLDATETIME

		/* разбиваем диапазон дат на недели*/
		IF @BEGIN > @END
			INSERT INTO @WEEK(WBEGIN, WEND) VALUES(@BEGIN, @END)
		ELSE
		BEGIN
			SET @TBEGIN = @BEGIN
			SET @TEND = DATEADD(DAY, 7 - DATEPART(WEEKDAY, @BEGIN), @BEGIN)

			IF @TEND >= @END
				SET @TEND = @END

			INSERT INTO @WEEK(WBEGIN, WEND) VALUES (@TBEGIN, @TEND)

			SET @TBEGIN = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @TBEGIN), @TBEGIN)

			WHILE @TEND < @END
			BEGIN
				SET @TBEGIN = DATEADD(WEEK, 1, @TBEGIN)
				SET @TEND = DATEADD(WEEK, 1, @TEND)

				IF @TEND >= @END
					SET @TEND = @END

				INSERT INTO @WEEK(WBEGIN, WEND) VALUES (@TBEGIN, @TEND)
			END
		END

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID	INT	PRIMARY KEY
			)

		INSERT INTO #client(CL_ID)
			SELECT ClientID
			FROM
				dbo.ClientTable
				INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND STATUS = 1

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				WEEK_ID		INT,
				WBEGIN		SMALLDATETIME,
				WEND		SMALLDATETIME,
				ER_COUNT	INT,
				ALL_COUNT	INT,
				PER			DECIMAL(8, 4)
			)

		INSERT INTO #res(WEEK_ID, WBEGIN, WEND, ER_COUNT, ALL_COUNT, PER)
			SELECT
				WEEK_ID, WBEGIN, WEND, ER_COUNT, ALL_COUNT,
				ROUND(
				CASE ALL_COUNT
					WHEN 0 THEN 0
					ELSE 100 * CONVERT(DECIMAL(8, 4), ER_COUNT) / ALL_COUNT
				END, 2) AS PER
			FROM
				(
					SELECT
						WEEK_ID, WBEGIN, WEND,
						(
							SELECT COUNT(DISTINCT UD_ID)
							FROM
								#client
								INNER JOIN USR.USRComplianceView WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
							WHERE UF_DATE BETWEEN WBEGIN AND WEND
								AND UF_COMPLIANCE = '#HOST'
						) AS ER_COUNT,
						(
							SELECT COUNT(DISTINCT UD_ID)
							FROM
								#client
								INNER JOIN USR.USRComplianceView WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
							WHERE UF_DATE BETWEEN WBEGIN AND WEND
						) AS ALL_COUNT
					FROM @WEEK
				) AS o_O
			ORDER BY WEEK_ID

		SELECT @PER_MIN = MIN(PER) FROM #res

		SELECT @PER_AVG = AVG(PER) FROM #res

		SELECT * FROM #res ORDER BY WEEK_ID

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[COMPLIANCE_GRAPH_REPORT] TO rl_report_compliance_graph;
GO