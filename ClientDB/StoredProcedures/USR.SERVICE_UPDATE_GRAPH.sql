USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[SERVICE_UPDATE_GRAPH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[SERVICE_UPDATE_GRAPH]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[SERVICE_UPDATE_GRAPH]
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		VARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res

		CREATE TABLE #res
			(
				ID				INT IDENTITY(1, 1) PRIMARY KEY,
				ClientFullName	VARCHAR(250),
				ClientAdress	VARCHAR(250),
				UpdateDateStart	SMALLDATETIME NULL,
				UpdateDateEnd	SMALLDATETIME,
				UpdateTime		INT NULL,
				ServiceTime		INT,
				RoadTime		INT,
				USR_KEY			BIT
			)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID	INT PRIMARY KEY,
				ClientFullName	VARCHAR(250),
				ClientAdress	VARCHAR(250),
				ServiceTime		INT
			)

		INSERT INTO #client(CL_ID, ClientFullName, ClientAdress, ServiceTime)
			SELECT ClientID, ClientFullName + ISNULL('(' + ServiceTypeShortName + ')', ''), CA_STR, ServiceTime
			FROM
				[dbo].[ClientList@Get?Read]()
				INNER JOIN dbo.ClientTable a ON ClientID = WCL_ID
				INNER JOIN dbo.GET_TABLE_FROM_LIST(@TYPE, ',') ON a.ServiceTypeID = Item
				LEFT OUTER JOIN dbo.ClientAddressView ON CA_ID_CLIENT = a.ClientID AND AT_REQUIRED = 1
				LEFT OUTER JOIN dbo.ServiceTypeTable b ON a.ServiceTypeID = b.ServiceTypeID
			WHERE ClientServiceID = @SERVICE;

		IF OBJECT_ID('tempdb..#update') IS NOT NULL
			DROP TABLE #update

		CREATE TABLE #update
			(
				UD_ID_CLIENT	INT,
				UIU_DATE		SMALLDATETIME,
				UIU_DATE_S		SMALLDATETIME,
				USR_KEY			BIT
			)

		INSERT INTO #update(UD_ID_CLIENT, UIU_DATE, UIU_DATE_S, USR_KEY)
			SELECT UD_ID_CLIENT, UIU_DATE, UIU_DATE_S, 0
			FROM
				#client
				INNER JOIN USR.USRIBDateView WITH(NOEXPAND) ON UD_ID_CLIENT = CL_ID
			WHERE UIU_DATE_S BETWEEN @BEGIN AND @END
				AND DATEPART(HOUR, UIU_DATE) BETWEEN 8 AND 18

			UNION ALL

			SELECT UD_ID_CLIENT, UF_DATE, dbo.DateOf(UF_DATE), 1
			FROM
				#client a
				INNER JOIN USR.USRData b ON b.UD_ID_CLIENT = a.CL_ID
				INNER JOIN USR.USRFile c ON b.UD_ID = c.UF_ID_COMPLECT
			WHERE UF_PATH = 3 AND dbo.DateOf(c.UF_DATE) BETWEEN @BEGIN AND @END


		DECLARE @SQL	NVARCHAR(MAX)

		SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(VARCHAR(50), NEWID()) + '] ON #update (UD_ID_CLIENT, UIU_DATE_S)'
		EXEC (@SQL)

		INSERT INTO #res
			(
				ClientFullName, ClientAdress, UpdateDateStart,
				UpdateDateEnd, ServiceTime, UpdateTime, USR_KEY
			)
			SELECT
				ClientFullName, ClientAdress,
				UpdateBeginDateTime, UpdateEndDateTime, ServiceTime,
				DATEDIFF(MINUTE, UpdateBeginDateTime, UpdateEndDateTime),
				USR_KEY
			FROM
				(
					SELECT DISTINCT
						ClientFullName, ClientAdress,
						CASE USR_KEY
							WHEN 0 THEN
								CONVERT(SMALLDATETIME, LEFT(CONVERT(VARCHAR(20), UIU_DATE_S, 120), 10) + ' ' +
									REPLACE((
										SELECT MAX(LEFT(CONVERT(VARCHAR(20), UIU_DATE, 108), 5))
										FROM #update z
										WHERE z.UD_ID_CLIENT = q.UD_ID_CLIENT
											AND z.UIU_DATE_S = q.UIU_DATE_S
											AND USR_KEY = 0
									), '.', ':') + ':00', 120)
							ELSE
								(
									SELECT TOP 1 UIU_DATE
									FROM #update z
									WHERE z.UD_ID_CLIENT = q.UD_ID_CLIENT
										AND z.UIU_DATE_S = q.UIU_DATE_S
										AND USR_KEY = 1
									ORDER BY UIU_DATE DESC
								)
						END AS UpdateEndDateTime, ServiceTime,
						CASE USR_KEY
							WHEN 0 THEN
								DATEADD(MINUTE, -5,
									CONVERT(SMALLDATETIME, LEFT(CONVERT(VARCHAR(20), UIU_DATE_S, 120), 10) + ' ' +
									REPLACE((
										SELECT MIN(LEFT(CONVERT(VARCHAR(20), UIU_DATE, 108), 5))
										FROM #update z
										WHERE z.UD_ID_CLIENT = q.UD_ID_CLIENT
											AND z.UIU_DATE_S = q.UIU_DATE_S
											AND USR_KEY = 0
									), '.', ':') + ':00', 120))
							ELSE
								(
									SELECT TOP 1 UIU_DATE
									FROM #update z
									WHERE z.UD_ID_CLIENT = q.UD_ID_CLIENT
										AND z.UIU_DATE_S = q.UIU_DATE_S
										AND USR_KEY = 1
									ORDER BY UIU_DATE
								)
						END AS UpdateBeginDateTime,
						USR_KEY
					FROM
						(
							SELECT DISTINCT
								UD_ID_CLIENT, ClientFullName, ClientAdress, UIU_DATE_S, ServiceTime, USR_KEY
							FROM
								#client
								INNER JOIN #update ON UD_ID_CLIENT = CL_ID
						) AS q
				) AS o_O
			ORDER BY UpdateBeginDateTime

		DECLARE @ID		INT
		DECLARE @DATE	VARCHAR(20)
		DECLARE @BDATE	SMALLDATETIME
		DECLARE @EDATE	SMALLDATETIME

		DECLARE @OLD_ID		INT
		DECLARE @OLD_DATE	VARCHAR(20)
		DECLARE @OLD_EDATE	SMALLDATETIME

		SET @OLD_DATE = ''

		SELECT
			@ID = ID, @DATE = CONVERT(VARCHAR(20), UpdateDateStart, 112),
			@BDATE = UpdateDateStart, @EDATE = UpdateDateEnd
		FROM #res
		WHERE ID = 1

		WHILE @ID IS NOT NULL
		BEGIN
			IF @OLD_DATE <> @DATE
			BEGIN
				SET @OLD_DATE = @DATE
			END
			ELSE
			BEGIN
				UPDATE #res
				SET RoadTime = DATEDIFF(MINUTE, @OLD_EDATE, @BDATE)
				WHERE ID = @OLD_ID
			END

			SET @OLD_ID = @ID
			SET @OLD_EDATE = @EDATE

			SELECT
				@ID = ID, @DATE = CONVERT(VARCHAR(20), UpdateDateStart, 112),
				@BDATE = UpdateDateStart, @EDATE = UpdateDateEnd
			FROM #res
			WHERE ID = (SELECT MIN(ID) FROM #res WHERE ID > @ID)

			IF @ID = @OLD_ID
				SET @ID = NULL
		END


		SELECT
			*,
			(
				SELECT COUNT(*)
				FROM #res b
				WHERE dbo.DateOf(a.UpdateDateStart) = dbo.DateOf(b.UpdateDateStart)
					AND DATEPART(HOUR, a.UpdateDateStart) = DATEPART(HOUR, b.UpdateDateStart)
			) AS HR_COUNT,
			CONVERT(NVARCHAR(64), UpdateDateStart, 104) + '   ' + [dbo].[WeekDateName](UpdateDateStart) AS DATE_STR,
			CONVERT(NVARCHAR(64), DATEPART(HOUR, UpdateDateStart)) + '-' + CONVERT(NVARCHAR(64), DATEPART(HOUR, UpdateDateStart) + 1) AS HR_STR
		FROM #res a
		ORDER BY ID

		IF OBJECT_ID('tempdb..#res') IS NOT NULL
			DROP TABLE #res
		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client
		IF OBJECT_ID('tempdb..#update') IS NOT NULL
			DROP TABLE #update

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[SERVICE_UPDATE_GRAPH] TO rl_report_graf_update;
GO
