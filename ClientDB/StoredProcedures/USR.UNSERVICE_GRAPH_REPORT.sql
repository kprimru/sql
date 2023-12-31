USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[UNSERVICE_GRAPH_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT
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

		/* ��������� �������� ��� �� ������ */
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

		SELECT
			WEEK_ID, WBEGIN, WEND, COUNT(*) AS RES_COUNT
		FROM
			@WEEK
			INNER JOIN USR.USRFile f ON UF_DATE BETWEEN WBEGIN AND WEND
			INNER JOIN USR.USRData ON UD_ID = UF_ID_COMPLECT
			INNER JOIN USR.USRFileTech t ON f.UF_ID = t.UF_ID
			INNER JOIN #client ON UD_ID_CLIENT = CL_ID
			INNER JOIN dbo.ResVersionTable ON ResVersionID = t.UF_ID_RES
			INNER JOIN dbo.ConsExeVersionTable ON ConsExeVersionID = t.UF_ID_CONS
		WHERE UF_ACTIVE = 1 AND UD_ACTIVE = 1
			AND
				(
					UF_DATE < ResVersionBegin
					OR UF_DATE > ISNULL(ResVersionEnd, GETDATE())
					OR UF_DATE < ConsExeVersionBegin
					OR UF_DATE > ISNULL(ConsExeVersionEnd, GETDATE())
				)
		GROUP BY WEEK_ID, WBEGIN, WEND

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
