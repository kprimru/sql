USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[CLIENT_PRICE_CHANGE_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[CLIENT_PRICE_CHANGE_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[CLIENT_PRICE_CHANGE_REPORT]
	@BEGIN		UNIQUEIDENTIFIER,
	@END		UNIQUEIDENTIFIER,
	@SERVICE	INT,
	@MANAGER	INT,
	@HIDE		BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@BEGIN_DATE		SmallDateTime,
		@END_DATE		SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL;

		SELECT @BEGIN_DATE = [START]
		FROM [Common].[Period]
		WHERE [ID] = @BEGIN;

		SELECT @END_DATE = [START]
		FROM [Common].[Period]
		WHERE [ID] = @END;

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID		INT PRIMARY KEY,
				ClientFullName	VARCHAR(500),
				ManagerName		VARCHAR(150),
				ServiceName		VARCHAR(150),
				SystemList		VARCHAR(MAX),
				DELTA			MONEY,
				DELTA_NDS		MONEY
			)

		INSERT INTO #client(ClientID, ClientFullName, ManagerName, ServiceName, SystemList)
			SELECT
				ClientID, ClientFullName, ManagerName, ServiceName,
				REVERSE(STUFF(REVERSE(
					(
						SELECT DistrStr + ' (' + DistrTypeName + '), '
						FROM dbo.ClientDistrView
						WHERE ID_CLIENT = ClientID AND DS_REG = 0
						ORDER BY SystemOrder, DISTR, COMP FOR XML PATH('')
					)), 1, 2, ''))
			FROM dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
			WHERE	(ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)

		UPDATE a
		SET DELTA = PRICE_DELTA,
			DELTA_NDS = PRICE_NDS_DELTA
		FROM
			#client a
			INNER JOIN
				(
					SELECT
						ClientID,
						SUM(PRICE_DELTA) AS PRICE_DELTA,
						SUM(PRICE_NDS_DELTA) AS PRICE_NDS_DELTA
					FROM
						(
							SELECT
								ClientID,
								NEW_PRICE - OLD_PRICE AS PRICE_DELTA,
								ROUND(NEW_PRICE * e.TOTAL_RATE, 2) - ROUND(OLD_PRICE * b.TOTAL_RATE, 2) AS PRICE_NDS_DELTA
							FROM
								(
									SELECT
										ClientID,
										DSS_REPORT * CASE
											WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN DF_FIXED_PRICE
											ELSE
												ROUND(ROUND(op.PRICE * dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE), dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE)) * (100 - ISNULL(DF_DISCOUNT, 0)) / 100, 2)
										END AS OLD_PRICE,
										DSS_REPORT * CASE
											WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN DF_FIXED_PRICE
											ELSE
												ROUND(ROUND(np.PRICE * dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE), dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE)) * (100 - ISNULL(DF_DISCOUNT, 0)) / 100, 2)
										END AS NEW_PRICE
									FROM
										#client
										INNER JOIN dbo.ClientDistrView a WITH(NOEXPAND) ON ClientID = ID_CLIENT
										INNER JOIN [Price].[Systems:Price@Get](@BEGIN_DATE) AS op ON op.[System_Id] = a.[SystemID]
										INNER JOIN [Price].[Systems:Price@Get](@END_DATE) AS np ON np.[System_Id] = a.[SystemID]
										LEFT OUTER JOIN dbo.DBFDistrView ON SystemBaseName = SYS_REG_NAME AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
									WHERE DS_REG = 0
								) AS a
								OUTER APPLY Common.TaxDefaultSelect(@BEGIN_DATE) AS b
								OUTER APPLY Common.TaxDefaultSelect(@END_DATE)	AS e
						) AS a
					GROUP BY ClientID
				) AS b ON a.ClientID = b.ClientID

		SELECT
			ClientID, ManagerName, ServiceName, ClientFullName, SystemList, DELTA, DELTA_NDS,
			ROW_NUMBER() OVER(PARTITION BY ManagerName, ServiceName ORDER BY ClientFullName) AS RN
		FROM #client
		WHERE (@HIDE = 0 OR DELTA <> 0)
		ORDER BY ManagerName, ServiceName, ClientFullName

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
GRANT EXECUTE ON [Price].[CLIENT_PRICE_CHANGE_REPORT] TO rl_price_history;
GO
