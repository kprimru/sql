USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[UPDATE_PERIOD_AUDIT]
	@MANAGER	INT,
	@SERVICE	INT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		VARCHAR(MAX)
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		DECLARE @WEEK TABLE
			(
				WEEK_ID	INT PRIMARY KEY,
				WBEGIN	SMALLDATETIME,
				WEND	SMALLDATETIME
			)

		INSERT INTO @WEEK
			SELECT *
			FROM dbo.WeekDates(@BEGIN, @END)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID	INT PRIMARY KEY,
				ClientFullName	VARCHAR(500),
				ServiceName		VARCHAR(150),
				ManagerName		VARCHAR(150)
			)

		INSERT INTO #client(ClientID, ClientFullName, ServiceName, ManagerName)
			SELECT ClientID, ClientFullName + ' (' + ServiceTypeShortName + ')', ServiceName, ManagerName
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ServiceTypeID
				INNER JOIN dbo.ServiceTypeTable b ON a.ServiceTypeID = b.ServiceTypeID
			WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)

		IF OBJECT_ID('tempdb..#client_banks') IS NOT NULL
			DROP TABLE #client_banks

		CREATE TABLE #client_banks
			(
				ClientID		INT,
				ClientFullName	VARCHAR(500),
				ServiceName		VARCHAR(150),
				ManagerName		VARCHAR(150),
				DistrStr		VARCHAR(100),
				Period			VARCHAR(100),
				WBEGIN			SMALLDATETIME,
				WEND			SMALLDATETIME,
				DIS_NUM			INT,
				DIS_COMP		TINYINT,
				IB_ID			INT,
				IB_SHORT		VARCHAR(50),
				SYS_ORDER		INT,
				IB_ORDER		INT
			)

		INSERT INTO #client_banks(ClientID, ClientFullName, ServiceName, ManagerName, DistrStr, Period, WBEGIN, WEND, DIS_NUM, DIS_COMP, IB_ID, IB_SHORT, SYS_ORDER, IB_ORDER)
			SELECT
				a.ClientID, ClientFullName, ServiceName, ManagerName, DistrStr,
				'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS Period,
				WBEGIN, WEND, DISTR, COMP, InfoBankID, InfoBankShortName, b.SystemOrder, InfoBankOrder
			FROM
				#client a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
				CROSS APPLY dbo.SystemBankGet(b.SystemID, b.DistrTypeId) c
				CROSS JOIN @WEEK
			WHERE InfoBankActive = 1 AND DS_REG = 0 AND Required = 1 AND c.SystemBaseName NOT IN ('RGN', 'RGU')

			UNION ALL

			SELECT
				a.ClientID, ClientFullName, ServiceName, ManagerName, DistrStr,
				'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS Period,
				WBEGIN, WEND, DISTR, COMP, InfoBankID, InfoBankShortName, b.SystemOrder, InfoBankOrder
			FROM
				#client a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
				INNER JOIN dbo.DistrConditionView c ON b.SystemID = c.SystemID
													AND DISTR = DistrNumber
													AND COMP = CompNumber
				CROSS JOIN @WEEK
			WHERE DS_REG = 0 AND b.SystemBaseName NOT IN ('RGN', 'RGU')

			UNION ALL

			SELECT
				a.ClientID, ClientFullName, ServiceName, ManagerName, DistrStr,
				'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS Period,
				WBEGIN, WEND, DISTR, COMP, InfoBankID, InfoBankShortName, b.SystemOrder, InfoBankOrder
			FROM
				#client a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
				CROSS APPLY dbo.SystemBankGet(b.SystemID, b.DIstrTypeID) c
				CROSS JOIN @WEEK
			WHERE InfoBankActive = 1 AND DS_REG = 0 AND Required = 0 AND b.SystemBaseName NOT IN ('RGN', 'RGU')
				AND EXISTS
					(
						SELECT *
						FROM
							USR.USRActiveView
							INNER JOIN USR.USRIB ON UI_ID_USR = UF_ID
						WHERE UD_ID_CLIENT = a.ClientID
							AND UI_DISTR = DISTR
							AND UI_COMP = COMP
							AND UI_ID_BASE = c.InfoBankID
					)


		IF OBJECT_ID('tempdb..#ib') IS NOT NULL
			DROP TABLE #ib

		CREATE TABLE #ib
			(
				UD_ID_CLIENT	INT,
				UI_ID_BASE		INT,
				UI_DISTR		INT,
				UI_COMP			TINYINT,
				UIU_DATE_S		SMALLDATETIME
			)

		INSERT INTO #ib(UD_ID_CLIENT, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S)
			SELECT UD_ID_CLIENT, UI_ID_BASE, UI_DISTR, UI_COMP, UIU_DATE_S
			FROM
				#client a
				INNER JOIN USR.USRIBDateView WITH(NOEXPAND) ON a.ClientID = UD_ID_CLIENT
			WHERE UIU_DATE_S BETWEEN @BEGIN AND @END

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE CLUSTERED INDEX [IX_' + CONVERT(NVARCHAR(128), NEWID()) + '] ON #ib (UD_ID_CLIENT, UIU_DATE_S, UI_ID_BASE, UI_DISTR, UI_COMP)'
		EXEC (@SQL)

		SELECT
			a.ClientID, ClientFullName, ServiceName, ManagerName,
			DistrStr,
			IB_SHORT AS InfoBankShortName,
			'с ' + CONVERT(VARCHAR(20), WBEGIN, 104) + ' по ' + CONVERT(VARCHAR(20), WEND, 104) AS Period,
			(
				SELECT TOP 1 UIU_DATE_S
				FROM USR.USRIBDateView WITH(NOEXPAND)
				WHERE UD_ID_CLIENT = a.ClientID
					AND UI_ID_BASE = IB_ID
					AND UI_DISTR = DIS_NUM
					AND UI_COMP = DIS_COMP
					AND UIU_DATE_S <= @END
				ORDER BY UIU_DATE_S DESC
			) AS LAST_UPDATE
		FROM #client_banks a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM #ib
				WHERE UD_ID_CLIENT = a.ClientID
					AND UI_ID_BASE = IB_ID
					AND UI_DISTR = DIS_NUM
					AND UI_COMP = DIS_COMP
					AND UIU_DATE_S BETWEEN WBEGIN AND WEND
			)
			AND EXISTS
			(
				SELECT *
				FROM #ib
				WHERE UD_ID_CLIENT = a.ClientID
					AND UIU_DATE_S BETWEEN WBEGIN AND WEND
			)
			/*
			AND EXISTS
			(
				SELECT *
				FROM USR.USRData
				WHERE UD_ID_CLIENT = a.ClientID AND UD_ACTIVE = 1
			)*/
		ORDER BY ManagerName, ServiceName, ClientFullName, WBEGIN, SYS_ORDER, DIS_NUM, DIS_COMP, IB_ORDER, IB_SHORT

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#client_banks') IS NOT NULL
			DROP TABLE #client_banks

		IF OBJECT_ID('tempdb..#ib') IS NOT NULL
			DROP TABLE #ib

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [USR].[UPDATE_PERIOD_AUDIT] TO rl_update_period_audit;
GO