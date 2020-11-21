USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_REPORT_CREATE]
	@SERVICE	INT,
	@MANAGER	INT,
	@CSTATUS	VARCHAR(MAX),
	@SSTATUS	VARCHAR(MAX),
	@DATE		SMALLDATETIME
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

		IF OBJECT_ID('tempdb..#cstatus') IS NOT NULL
			DROP TABLE #cstatus

		CREATE TABLE #cstatus(ST_ID INT)

		INSERT INTO #cstatus(ST_ID)
			SELECT ID
			FROM dbo.TableIDFromXML(@cstatus)

		IF OBJECT_ID('tempdb..#sstatus') IS NOT NULL
			DROP TABLE #sstatus

		CREATE TABLE #sstatus(ST_ID UNIQUEIDENTIFIER)

		INSERT INTO #sstatus(ST_ID)
			SELECT ID
			FROM dbo.TableGUIDFromXML(@sstatus)


		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				CL_ID	INT
			)

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		INSERT INTO #client(CL_ID)
			SELECT ClientID
			FROM
				dbo.ClientTable
				INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
				INNER JOIN #cstatus ON ST_ID = StatusID
			WHERE (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
				AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
				AND STATUS = 1

		IF OBJECT_ID('tempdb..#host') IS NOT NULL
			DROP TABLE #host

		CREATE TABLE #host
			(
				HST_ID	INT
			)

		INSERT INTO #host(HST_ID)
			SELECT DISTINCT b.HostID
			FROM
				dbo.SystemTable a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.SystemID = b.SystemID
				INNER JOIN #client ON ID_CLIENT = CL_ID
				INNER JOIN #sstatus ON ST_ID = DS_ID

		IF OBJECT_ID('tempdb..#data') IS NOT NULL
			DROP TABLE #data

		CREATE TABLE #data
			(
				CL_ID	INT PRIMARY KEY,
				NUM	INT,
				CL_NAME	VARCHAR(250),
				CO_COND	VARCHAR(250),
				CO_FIXED MONEY,
				CO_TYPE	VARCHAR(100),
				PAY_TYPE	VARCHAR(100),
				CLIENT_PAY	VARCHAR(100),
				PAPPER	INT,
				BOOK	INT,
				NET		VARCHAR(50),
				PAY_DATE	SMALLDATETIME,
				CSTATUS	VARCHAR(50)
		)

		INSERT INTO #data(CL_ID, CL_NAME, CO_COND, CO_FIXED, CO_TYPE, PAY_TYPE, CLIENT_PAY, PAPPER, BOOK, NET, CSTATUS)
			SELECT
				ClientID, ClientFullName,
				D.Comments, D.ContractPrice, D.ContractTypeName, D.ContractPayName,
				PayTypeName, ClientNewspaper, ClientMainBook,
				(
					SELECT TOP 1 NT_SHORT
					FROM
						dbo.ClientDistrView y WITH(NOEXPAND)
						INNER JOIN Din.NetType z ON z.NT_ID_MASTER = y.DistrTypeId
						INNER JOIN #sstatus ON ST_ID = y.DS_ID
					WHERE y.ID_CLIENT = a.CLientID
					ORDER BY NT_NET DESC, NT_TECH DESC
				),
				ServiceStatusName
			FROM
				#client
				INNER JOIN dbo.ClientTable a ON a.ClientID = CL_ID
				INNER JOIN dbo.ServiceStatusTable ON StatusID = ServiceStatusID
				LEFT OUTER JOIN dbo.PayTypeTable b ON a.PayTypeID = b.PayTypeID
				OUTER APPLY
				(
					SELECT TOP (1) D.Comments, ContractPrice, ContractTypeName, ContractPayName
					FROM Contract.ClientContracts CC
					INNER JOIN Contract.Contract C ON CC.Contract_Id = C.ID
					CROSS APPLY
					(
						SELECT TOP (1) ContractPrice, Type_Id, PayType_Id, Comments
						FROM Contract.ClientContractsDetails D
						WHERE D.Contract_Id = C.Id
						ORDER BY D.DATE DESC
					) D
					INNER JOIN dbo.ContractTypeTable T ON D.Type_Id = T.ContractTypeID
					INNER JOIN dbo.ContractPayTable P ON D.PayType_Id = P.ContractPayID
					WHERE CC.Client_Id = a.ClientID
						AND C.DateTo IS NULL
						AND [Maintenance].[GlobalContractOld]() = 0

				    UNION ALL

				    SELECT TOP (1) ContractConditions, ContractFixed, ContractTypeName, ContractPayName
				    FROM dbo.ContractTable z
				    INNER JOIN dbo.ContractTypeTable y ON z.ContractTypeID = y.ContractTypeID
				    INNER JOIN dbo.ContractPayTable x ON z.ContractPayID = x.ContractPayID
				    WHERE z.ClientID = a.ClientID
				    	AND ContractBegin < GETDATE()
				    	AND [Maintenance].[GlobalContractOld]() = 1
				    ORDER BY ContractBegin DESC
				) D

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				CL_ID		INT,
				HST_ID		INT,
				HST_SHORT	VARCHAR(50),
				HST_ORDER	INT,
				SYS_ID		INT,
				SYS_SHORT	VARCHAR(50),
				NET			VARCHAR(50),
				DIS_STR		VARCHAR(50),
				DIS			INT,
				COMP		TINYINT,
				SSTATUS		VARCHAR(50)
			)

		INSERT INTO #distr(CL_ID, HST_ID, HST_SHORT, HST_ORDER, SYS_ID, SYS_SHORT, NET, DIS_STR, DIS, COMP, SSTATUS)
			SELECT
				ID_CLIENT, d.HostID, d.HostShort, HostOrder, c.SystemID, c.SystemShortName, b.DistrTypeName,
				dbo.DistrString(NULL, DISTR, COMP), DISTR, COMP, b.DS_NAME
			FROM
				#client a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.CL_ID = b.ID_CLIENT
				INNER JOIN dbo.SystemTable c ON c.SystemID = b.SystemID
				INNER JOIN dbo.Hosts d ON c.HostID = d.HostID
				INNER JOIN dbo.DistrTypeTable e ON e.DistrTypeID = b.DistrTypeID
				INNER JOIN #sstatus ON ST_ID = b.DS_ID
				INNER JOIN dbo.DistrStatus f ON f.DS_ID = b.DS_ID

		UPDATE #data
		SET NUM =
			(
				SELECT MIN(ROW)
				FROM
					(
						SELECT ROW_NUMBER() OVER(ORDER BY HST_ORDER, DIS, COMP) AS ROW, CL_ID AS CLIENT
						FROM #distr
					) AS o_O
				WHERE CL_ID = CLIENT
			)

		DECLARE @ID	UNIQUEIDENTIFIER

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO dbo.ServiceReport(SR_SERVICE, SR_MANAGER, SR_CSTATUS, SR_SSTATUS, SR_DATE)
			OUTPUT INSERTED.SR_ID INTO @TBL
			SELECT
				(
					SELECT	ServiceName
					FROM	dbo.ServiceTable
					WHERE	ServiceID = @SERVICE
				),
				(
					SELECT	ManagerName
					FROM	dbo.ManagerTable
					WHERE	ManagerID = @MANAGER
				),
				REVERSE(STUFF(REVERSE(
					(
						SELECT	ServiceStatusName + ','
						FROM
							dbo.ServiceStatusTable
							INNER JOIN #cstatus ON ST_ID = ServiceStatusID
						ORDER BY ServiceStatusName FOR XML PATH('')
					)
				), 1, 1, '')),
				REVERSE(STUFF(REVERSE(
					(
						SELECT	DS_NAME + ','
						FROM
							dbo.DistrStatus
							INNER JOIN #sstatus ON ST_ID = DS_ID
						ORDER BY DS_NAME FOR XML PATH('')
					)
				), 1, 1, '')),
				@DATE


		SELECT @ID = ID
		FROM @TBL

		INSERT INTO dbo.ServiceReportClient(
					SRC_ID_SR, SRC_ID_CLIENT, SRC_NAME, SCR_CO_COND, SRC_CO_TYPE,
					SRC_PAY_TYPE, SRC_CLIENT_PAY, SRC_PAPPER, SRC_BOOK, SRC_NET, SRC_STATUS)
			SELECT
					@ID, CL_ID, CL_NAME, CO_COND, CO_TYPE,
					PAY_TYPE, CLIENT_PAY, PAPPER, BOOK, NET, CSTATUS
			FROM #data

		INSERT INTO dbo.ServiceReportDistr(
					SRD_ID_SR, SRD_ID_CLIENT, SRD_HST, SRD_HST_NAME, SRD_HST_ORDER,
					SRD_SYS, SRD_SYS_NAME, SRD_NET,
					SRD_DIS_STR, SRD_DIS_NUM, SRD_DIS_COMP, SRD_STATUS)
			SELECT
					@ID, CL_ID, HST_ID, HST_SHORT, HST_ORDER,
					SYS_ID, SYS_SHORT, NET,
					DIS_STR, DIS, COMP, SSTATUS
			FROM #distr

		SELECT HostID, HostShort
		FROM
			dbo.Hosts
			INNER JOIN #host ON HostID = HST_ID
		ORDER BY HostOrder

		SELECT DISTINCT CL_ID
		FROM #data

		SELECT
			a.CL_ID, CL_NAME, CO_COND, CO_FIXED, CO_TYPE, PAY_TYPE, CLIENT_PAY, PAPPER, BOOK, a.NET, PAY_DATE,
			HST_ID, HST_SHORT, SYS_SHORT, b.NET AS DIS_NET, DIS_STR
		FROM
			#data a LEFT OUTER JOIN
			#distr b ON a.CL_ID = b.CL_ID
		ORDER BY NUM

		SELECT DistrTypeID, DistrTypeName
		FROM dbo.DistrTypeTable
		ORDER BY DistrTypeOrder

		SELECT
			HST_ID, DistrTypeID,
			(
				SELECT COUNT(*)
				FROM #distr c
				WHERE NET = DistrTypeName AND b.HST_ID = c.HST_ID
			) AS CNT
		FROM
			dbo.DistrTypeTable a
			CROSS JOIN #host b


		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		IF OBJECT_ID('tempdb..#data') IS NOT NULL
			DROP TABLE #data

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		IF OBJECT_ID('tempdb..#host') IS NOT NULL
			DROP TABLE #host

		IF OBJECT_ID('tempdb..#sstatus') IS NOT NULL
			DROP TABLE #sstatus

		IF OBJECT_ID('tempdb..#cstatus') IS NOT NULL
			DROP TABLE #cstatus

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_REPORT_CREATE] TO rl_service_report;
GO