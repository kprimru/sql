USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_FULL_SEARCH_NEW]
	@NAME			VARCHAR(100) = NULL,
	@ADDRESS		VARCHAR(100) = NULL,
	@SYS			INT = NULL,
	@DISTR			VARCHAR(50) = NULL,
	@STATUS			INT = NULL,
	@SERVICE_TYPE	INT = NULL,
	@MANAGER		INT = NULL,
	@SERVICE		INT = NULL,
	@DIR			VARCHAR(100) = NULL,
	@BUH			VARCHAR(100) = NULL,
	@CONTRACT		INT = NULL,
	@TYPE			INT = NULL,
	@CONTROL		BIT = NULL,
	@ORI			BIT = NULL,
	@BOOK			BIT = NULL,
	@COUNT			INT = NULL OUTPUT,
	@PCOUNT			INT = NULL OUTPUT,
	@BCOUNT			INT = NULL OUTPUT,
	@DISCONNECT		SMALLDATETIME = NULL,
	@LAWYER			UNIQUEIDENTIFIER = NULL,
	@TRADE_SITE		UNIQUEIDENTIFIER = NULL,
	@PLACE_ORDER	UNIQUEIDENTIFIER = NULL,
	@SIMPLE			VARCHAR(250) = NULL,
	@DISC_BEGIN		SMALLDATETIME = NULL,
	@DISC_END		SMALLDATETIME = NULL,
	@HIST			BIT = 0,
	@PERSONAL_DEEP	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;	

	IF @HIST IS NULL
		SET @HIST = 0

	DECLARE @rclient TABLE
		(
			RCL_ID	INT PRIMARY KEY CLUSTERED
		)

	INSERT INTO @rclient(RCL_ID)
		SELECT RCL_ID
		FROM dbo.ClientReadList()

	DECLARE @client TABLE
		(
			CL_ID	INT PRIMARY KEY CLUSTERED
		)
		
	DECLARE @CUR_DATE SMALLDATETIME
	
	SET @CUR_DATE = dbo.DateOf(GETDATE())
		
	IF @SIMPLE IS NULL
	BEGIN
		IF (@SYS IS NOT NULL) OR (@DISTR IS NOT NULL)
			INSERT INTO @client(CL_ID)
				SELECT DISTINCT ID_CLIENT
				FROM dbo.ClientDistrView WITH(NOEXPAND)
				WHERE ((SystemID = @SYS) OR (@SYS IS NULL))
					AND ((CONVERT(VARCHAR(20), DISTR) LIKE @DISTR) OR (@DISTR IS NULL))			
		ELSE IF @NAME IS NOT NULL AND @HIST = 0
			INSERT INTO @client(CL_ID)							
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE STATUS = 1
					AND
					(
						ClientFullName LIKE @NAME
						OR EXISTS
							(
								SELECT *
								FROM dbo.ClientNames
								WHERE ID_CLIENT = ClientID
									AND NAME LIKE @NAME
							)
						OR ClientShortName LIKE @NAME
						OR CONVERT(VARCHAR(20), ClientID) = REPLACE(@NAME, '%', '')
					)		
		ELSE IF @SERVICE IS NOT NULL
			INSERT INTO @client(CL_ID)
				SELECT ClientID
				FROM dbo.ClientTable
				WHERE ClientServiceID = @SERVICE
					AND STATUS = 1
		ELSE		
			INSERT INTO @client(CL_ID)
				SELECT RCL_ID
				FROM @rclient

				
		DELETE
		FROM @client
		WHERE CL_ID NOT IN
			(
				SELECT RCL_ID
				FROM @rclient
			)
		
	
		IF (@SYS IS NOT NULL) OR (@DISTR IS NOT NULL)
		BEGIN
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ID_CLIENT
					FROM dbo.ClientDistrView WITH(NOEXPAND)
					WHERE ((SystemID = @SYS) OR (@SYS IS NULL))
						AND ((CONVERT(VARCHAR(20), DISTR) LIKE @DISTR) OR (@DISTR IS NULL))	
				)
		END	

		IF @DIR IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT CP_ID_CLIENT
					FROM dbo.ClientPersonal
					WHERE ISNULL(CP_SURNAME + ' ', '') + ISNULL(CP_NAME + ' ', '') + ISNULL(CP_PATRON, '') LIKE @DIR 
						OR CP_PHONE LIKE @DIR 
						OR CP_PHONE_S LIKE @DIR
						OR CP_POS LIKE @DIR
						
					UNION
					
					SELECT ClientID
					FROM dbo.ClientPersonalOtherView
					WHERE @PERSONAL_DEEP = 1
						AND (
								ISNULL(SURNAME + ' ', '') + ISNULL(NAME + ' ', '') + ISNULL(PATRON, '') LIKE @DIR 
								OR PHONE LIKE @DIR 
								OR POS LIKE @DIR
							)					
				)		

		IF @ADDRESS IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT CA_ID_CLIENT
					FROM dbo.ClientAddressView
					WHERE CA_STR LIKE @ADDRESS
						AND AT_REQUIRED = 1
				)			

		IF @NAME IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientFullName LIKE @NAME
						OR EXISTS
						(
							SELECT *
							FROM dbo.ClientNames
							WHERE ID_CLIENT = ClientID
								AND NAME LIKE @NAME
						)
						OR ClientShortName LIKE @NAME
						OR CONVERT(VARCHAR(20), ClientID) = REPLACE(@NAME, '%', '')
						
					UNION
					
					SELECT ID_MASTER
					FROM dbo.ClientTable
					WHERE (ClientFullName LIKE @NAME
						OR ClientShortName LIKE @NAME)
						AND @HIST = 1
						AND STATUS <> 1
				)		
	
		IF @CONTRACT IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientContractTypeID = @CONTRACT
				)

	

		IF @STATUS IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE StatusID = @STATUS
				)

		IF @SERVICE_TYPE IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ServiceTypeID = @SERVICE_TYPE
				)

		IF @MANAGER IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM 
						dbo.ClientTable
						INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
					WHERE ManagerID = @MANAGER AND STATUS = 1
				)

		IF @SERVICE IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientServiceID = @SERVICE
						AND STATUS = 1
				)

		IF @TYPE IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM 
						dbo.ClientTypeAllView a
						INNER JOIN dbo.ClientTypeTable b ON b.ClientTypeName = a.CATEGORY
					WHERE ClientTypeID = @TYPE
				)

		IF @CONTROL = 1
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT CC_ID_CLIENT
					FROM dbo.ClientControl
					WHERE CC_REMOVE_DATE IS NULL
						AND (CC_BEGIN IS NULL OR CC_BEGIN <= @CUR_DATE)
				)

		IF @ORI = 1
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE OriClient = 1
				)

		IF @DISCONNECT IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM 
						(
							SELECT ClientID, MAX(DisconnectDate) AS DisconnectDate
							FROM dbo.ClientDisconnectView WITH(NOEXPAND)
							GROUP BY ClientID
						) AS o_O
					WHERE DisconnectDate >= @DISCONNECT
				)

		IF @DISC_BEGIN IS NOT NULL OR @DISC_END IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM 
						(
							SELECT ClientID, MAX(DisconnectDate) AS DisconnectDate
							FROM dbo.ClientDisconnectView WITH(NOEXPAND)
							GROUP BY ClientID
						) AS o_O
					WHERE (DisconnectDate >= @DISC_BEGIN OR @DISC_BEGIN IS NULL)
						AND (DisconnectDate <= @DISC_END OR @DISC_END IS NULL)
				)		
	END
	ELSE
	BEGIN
		INSERT INTO @client(CL_ID)
			SELECT RCL_ID
			FROM @rclient

		DECLARE @search TABLE
			(
				WRD		VARCHAR(250) PRIMARY KEY CLUSTERED
			)		

		INSERT INTO @search(WRD)
			SELECT DISTINCT '%' + Word + '%'
			FROM dbo.SplitString(@SIMPLE)		
		
		IF @STATUS IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE StatusID = @STATUS
				)

		IF @SERVICE IS NOT NULL
			DELETE FROM @client
			WHERE CL_ID NOT IN
				(
					SELECT ClientID
					FROM dbo.ClientTable
					WHERE ClientServiceID = @SERVICE
						AND STATUS = 1
				)

		DELETE 
		FROM @client
		WHERE CL_ID IN
			(
				SELECT ID_CLIENT
				FROM dbo.ClientIndex z WITH(NOLOCK)
				WHERE EXISTS
					(
						SELECT * 
						FROM @search 
						WHERE NOT (DATA LIKE WRD)
					)
			)
	END

	DECLARE @names TABLE
		(
			CL_ID	INT PRIMARY KEY CLUSTERED,
			NAMES	VARCHAR(MAX)
		)
		
	INSERT INTO @names(CL_ID, NAMES)
		SELECT t.CL_ID, 
			REVERSE(STUFF(REVERSE(
			(
				SELECT NAME + '; '
				FROM dbo.ClientNames
				WHERE ID_CLIENT = t.CL_ID
				ORDER BY NAME FOR XML PATH('')
			)), 1, 2, ''))
		FROM @client t

	SELECT 
		a.ClientID, 
		ClientFullName,
		NAMES AS ClientParallelName, 
		CONVERT(VARCHAR(255), CA_STR) AS ClientAdress, 
		ServiceName, ManagerName,				
		ServiceStatusIndex, OriClient,		
			
		CONVERT(BIT, CASE 
			WHEN EXISTS
				(
					SELECT *
					FROM dbo.ClientControl
					WHERE CC_ID_CLIENT = t.CL_ID
						AND CC_REMOVE_DATE IS NULL
						AND (CC_BEGIN IS NULL OR CC_BEGIN <= @CUR_DATE)
				) THEN 1
			ELSE 0
		END) AS ClientControl,
		CONVERT(BIT, CASE
			WHEN EXISTS
				(
					SELECT *
					FROM dbo.ClientTrustView WITH(NOEXPAND)	
					WHERE CT_TRUST = 0 AND CT_MAKE IS NULL AND CC_ID_CLIENT = a.ClientID
				) THEN 1
			ELSE 0
		END) AS ClientTrust,
		CONVERT(BIT, CASE
			WHEN EXISTS
				(
					SELECT *
					FROM dbo.ClientSystemErrorView z WITH(NOEXPAND)
					WHERE z.ClientID = t.CL_ID
				) THEN 1
			ELSE 0
		END) AS ClientRegError,
		CONVERT(BIT, 0/*CASE 
			WHEN EXISTS
				(
					SELECT *
					FROM 
						dbo.ClientDistrView z WITH(NOEXPAND)
						INNER JOIN dbo.BLACK_LIST_REG y ON z.DISTR = y.DISTR AND z.COMP = y.COMP AND z.SystemID = y.ID_SYS
					WHERE z.ID_CLIENT = t.CL_ID AND P_DELETE = 0 AND z.DS_REG = 0
				) THEN 1
			ELSE 0
		END*/) AS IPLock,
		(
			SELECT TOP 1 DATE
			FROM 
				dbo.ClientSeminarDateView z WITH(NOEXPAND)
			WHERE z.ID_CLIENT = t.CL_ID
			ORDER BY DATE DESC
		) AS LAST_SEMINAR,
		DayName,
		DayOrder,
		ServiceStart,
		CONVERT(BIT, CASE 
			WHEN EXISTS
				(
					SELECT *
					FROM
						Control.ClientControl a
						LEFT OUTER JOIN Control.ControlGroup c ON a.ID_GROUP = c.ID
					WHERE REMOVE_DATE IS NULL
						AND a.ID_CLIENT = t.CL_ID
						AND (NOTIFY IS NULL OR NOTIFY <= GETDATE())
						AND (
								a.RECEIVER = ORIGINAL_LOGIN()
								OR
								(c.PSEDO = 'MANAGER' AND IS_MEMBER('rl_control_manager') = 1 AND ID_CLIENT IN (SELECT WCL_ID FROM dbo.ClientWriteList()))
								OR
								(c.PSEDO = 'LAW' AND IS_MEMBER('rl_control_law') = 1)
								OR
								(c.PSEDO = 'DUTY' AND IS_MEMBER('rl_control_duty') = 1)
								OR
								(c.PSEDO = 'AUDIT' AND IS_MEMBER('rl_control_audit') = 1)
								OR
								(c.PSEDO = 'CHIEF' AND IS_MEMBER('rl_control_chief') = 1)
								OR
								(c.PSEDO = 'TEACHER' AND IS_MEMBER('rl_control_teacher') = 1)
							)
				) THEN 1
			ELSE 0
		END) AS ClientControlNew
		--,h.CATEGORY
	FROM 
		@client t
		INNER JOIN dbo.ClientTable a ON t.CL_ID = a.ClientID
		INNER JOIN dbo.ServiceTable b ON a.ClientServiceID = b.ServiceID
		INNER JOIN dbo.ManagerTable c ON c.ManagerID = b.ManagerID
		INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.StatusID 
		LEFT OUTER JOIN dbo.ClientAddressView e ON a.ClientID = e.CA_ID_CLIENT AND e.AT_REQUIRED = 1
		LEFT OUTER JOIN @names f ON f.CL_ID = t.CL_ID
		LEFT OUTER JOIN dbo.DayTable g ON g.DayID = a.DayID
		--LEFT OUTER JOIN dbo.ClientTypeAllView h ON t.CL_ID = h.ClientID
	ORDER BY ClientFullName
	OPTION (RECOMPILE)
	
	
	--!!!ÏÎÑËÅÄÍÈÉ ÑÅÌÈÍÀÐ!!!!
	
	SELECT @COUNT = COUNT(*), @PCOUNT = SUM(ClientNewsPaper), @BCOUNT = SUM(ClientMainBook)
	FROM @client INNER JOIN dbo.ClientTable ON CL_ID = ClientID
END
