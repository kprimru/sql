USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_UPDATE_FILTER]
	@MANAGER	INT,
	@SERVICE	INT,
	@STYPE		VARCHAR(MAX),
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@PROBLEM	BIT
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

		SET @END = DATEADD(DAY, 1, @END)

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ClientID		INT	PRIMARY KEY,
				ClientFullName	VARCHAR(250),
				ManagerName		VARCHAR(50),
				ServiceName		VARCHAR(50),
				ServiceType		VARCHAR(50)
			)

		INSERT INTO #client(ClientID, ClientFullName, ManagerName, ServiceName, ServiceType)
			SELECT
				ClientID, ClientFullName, ManagerName, ServiceName, ServiceTypeShortName
			FROM
				[dbo].[ClientList@Get?Read]()
				INNER JOIN dbo.ClientView a WITH(NOEXPAND) ON WCL_ID = ClientID
				INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId
				INNER JOIN dbo.GET_TABLE_FROM_LIST(@STYPE, ',') ON Item = ServiceTypeID
				INNER JOIN dbo.ServiceTypeTable b ON b.ServiceTypeID = a.ServiceTypeID
			WHERE	(ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND (ServiceID = @SERVICE	OR @SERVICE IS NULL);

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

		CREATE TABLE #usr
		(
			CL_ID		INT PRIMARY KEY,
			IB_LAST		SMALLDATETIME,
			USR_LAST	DATETIME
		)

		INSERT INTO #usr(CL_ID, IB_LAST)
		SELECT
			ClientID, UIU_DATE
		FROM #client
		CROSS APPLY
		(
			SELECT TOP 1 UIU_DATE
			FROM USR.USRIBDateView WITH(NOEXPAND)
			WHERE ClientID = UD_ID_CLIENT
				AND UIU_DATE_S < @END
			ORDER BY UIU_DATE DESC
		) D;

		/*
		UPDATE #usr
		SET USR_LAST =
			(
				SELECT MAX(UF_CREATE)
				FROM
					USR.USRFile
					INNER JOIN USR.USRData ON UD_ID = UF_ID_COMPLECT
					INNER JOIN USR.USRIB ON UI_ID_USR = UF_ID
				WHERE UD_ID_CLIENT = CL_ID
					AND UI_LAST = IB_LAST
			)*/

		SELECT
			ROW_NUMBER() OVER(ORDER BY ManagerName, ServiceName, ClientFullName) AS NUM,
			ClientID, ClientFullName, ManagerName, ServiceName, ServiceType,
			IB_LAST, USR_LAST, IB_CORRECT, USR_CORRECT,
			(
				SELECT CONVERT(VARCHAR(20), EventDate, 104) + ' ' + EventComment + CHAR(10)
				FROM EventTable z
				WHERE EventActive = 1
					AND o_O.ClientID = z.ClientID
					AND EventDate BETWEEN @BEGIN AND @END
				ORDER BY EventDate FOR XML PATH('')
			) AS COMMENT
		FROM
			(
				SELECT
					ClientID, ClientFullName, ManagerName, ServiceName, ServiceType, IB_LAST, USR_LAST,
					CONVERT(BIT,
						CASE
							WHEN IB_LAST >= @END OR IB_LAST < @BEGIN THEN 0
							ELSE 1
						END
					) AS IB_CORRECT,
					CONVERT(BIT,1/*0
						CASE
							WHEN USR_LAST >= @END OR USR_LAST < @BEGIN THEN 10
							ELSE 1
						END*/
					) AS USR_CORRECT
				FROM
					#client
					INNER JOIN #usr ON CL_ID = ClientID
			) AS o_O
		WHERE @PROBLEM = 0 OR USR_CORRECT = 0 OR IB_CORRECT = 0
		ORDER BY ManagerName, ServiceName, ClientFullName

		IF OBJECT_ID('tempdb..#usr') IS NOT NULL
			DROP TABLE #usr

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
GRANT EXECUTE ON [dbo].[CLIENT_UPDATE_FILTER] TO rl_filter_last_update;
GO
