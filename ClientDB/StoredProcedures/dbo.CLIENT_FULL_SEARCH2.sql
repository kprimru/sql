USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_FULL_SEARCH2]
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
	@KIND			SMALLINT = NULL,
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
	@PERSONAL_DEEP	BIT = 0,
	@DISTR_TYPE		VARCHAR(30) = NULL,
	@ISLARGE		INT = NULL,
	@ACTIVE_SYS		BIT = 0
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;	
	
	DECLARE
		@FilterType_DISTR		TinyInt,
		@FilterType_NAME		TinyInt,
		@FilterType_COMMON		TinyInt,
		@FilterType_DIR			TinyInt,
		@FilterType_ADDRESS		TinyInt,
		@FilterType_CONTROL		TinyInt,
		@FilterType_DISCONNECT	TinyInt,
		@FilterType_MANAGER		TinyInt;
	
	SET @FilterType_DISTR		= 1;
	SET @FilterType_NAME		= 2;
	SET @FilterType_COMMON		= 3;
	SET @FilterType_DIR			= 4;
	SET @FilterType_ADDRESS		= 5;
	SET @FilterType_CONTROL		= 6;
	SET @FilterType_DISCONNECT	= 7;
	SET @FilterType_MANAGER		= 8;
	
	DECLARE @AddressType_Id	UniqueIdentifier;

	DECLARE @Client_Id_FromName Int;
	
	DECLARE @CUR_DATE SMALLDATETIME;
	
	DECLARE @IDs Table
	(
		[Id]		Int		NOT NULL,
		Primary Key Clustered([Id])
	);
	
	DECLARE @WIDs Table
	(
		[Id]		Int		NOT NULL,
		Primary Key Clustered([Id])
	);
	
	DECLARE @IdByFilterType Table
	(
		[Id]		Int		NOT NULL,
		[Type]		TinyInt	NOT NULL
		Primary Key Clustered([Id], [Type])
	);

	DECLARE @UsedFilterTypes Table
	(
		[Type]		TinyInt	NOT NULL
		Primary Key Clustered([Type])
	);

	DECLARE @search Table
	(
		WRD		VARCHAR(250) PRIMARY KEY CLUSTERED
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @HIST IS NULL
			SET @HIST = 0;

		SET @CUR_DATE = dbo.DateOf(GETDATE());
		
		BEGIN TRY
			IF @NAME IS NOT NULL
				SET @Client_Id_FromName = Cast(REPLACE(@NAME, '%', '') AS Int);
		END TRY
		BEGIN CATCH
			SET @Client_Id_FromName = NULL;
		END CATCH
			
		SET @AddressType_Id = (SELECT TOP (1) AT_ID FROM dbo.AddressType WHERE AT_REQUIRED = 1);
			
		IF @SIMPLE IS NULL
		BEGIN
			IF (@SYS IS NOT NULL) OR (@DISTR IS NOT NULL) OR (@DISTR_TYPE IS NOT NULL) BEGIN
				INSERT INTO @IdByFilterType
				SELECT DISTINCT ID_CLIENT, @FilterType_DISTR
				FROM dbo.ClientDistrView WITH(NOEXPAND)
				WHERE ((SystemID = @SYS) OR (@SYS IS NULL))
					AND (@ACTIVE_SYS = 1 AND DS_REG = 0 OR @ACTIVE_SYS = 0 OR @ACTIVE_SYS IS NULL)
					AND ((CONVERT(VARCHAR(20), DISTR) LIKE @DISTR) OR (@DISTR IS NULL))
					AND (DistrTypeId = @DISTR_TYPE OR @DISTR_TYPE IS NULL)
				OPTION (RECOMPILE);
				
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_DISTR)
			END;
					
			IF @NAME IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT ClientID, @FilterType_NAME
				FROM
				(
					SELECT ClientID
					FROM dbo.ClientTable AS C
					WHERE STATUS = 1
						AND ClientFullName LIKE @NAME
						
						
					UNION
					
					SELECT ClientID
					FROM dbo.ClientTable AS C
					WHERE STATUS = 1
						AND ClientShortName LIKE @NAME
						
					UNION
					
					SELECT ClientID
					FROM dbo.ClientTable AS C
					WHERE STATUS = 1
						AND ClientOfficial LIKE @NAME
						
					UNION
					
					SELECT ClientID
					FROM dbo.ClientTable AS C
					WHERE STATUS = 1
						AND ClientID = @Client_Id_FromName 
					
					UNION 
					
					SELECT Id
					FROM [Cache].[Client?Names]	AS N
					WHERE N.[Names] LIKE @NAME
						
					UNION
						
					SELECT ID_MASTER
					FROM dbo.ClientTable
					WHERE ClientFullName LIKE @NAME
						AND @HIST = 1
						AND STATUS = 2
				) AS C
				OPTION (RECOMPILE);
				
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_NAME)
			END
					
			IF @SERVICE IS NOT NULL OR @ISLARGE IS NOT NULL OR @KIND IS NOT NULL OR @STATUS IS NOT NULL OR @SERVICE_TYPE IS NOT NULL OR @TYPE IS NOT NULL OR @ORI = 1 BEGIN
				INSERT INTO @IdByFilterType
				SELECT ClientID, @FilterType_COMMON
				FROM dbo.ClientTable
				WHERE (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND (@ISLARGE IS NULL OR @ISLARGE = 1 AND IsLarge = 1 OR @ISLARGE = 0 AND IsLarge = 0 OR @ISLARGE = 2)
					AND (ClientKind_Id = @KIND OR @KIND IS NULL)
					AND (StatusID = @STATUS OR @STATUS IS NULL)
					AND (ServiceTypeID = @SERVICE_TYPE OR @SERVICE_TYPE IS NULL)
					AND (ClientTypeID = @TYPE OR @TYPE IS NULL)
					AND (OriClient = 1 OR @ORI = 0 OR @ORI IS NULL)
					AND STATUS = 1
				OPTION (RECOMPILE);
				
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_COMMON)
			END;
					
					
			IF @DIR IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT CP_ID_CLIENT, @FilterType_DIR
				FROM
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
				) AS D;
				
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_DIR)
			END

			IF @ADDRESS IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT Id, @FilterType_ADDRESS
				FROM [Cache].[Client?Addresses]
				WHERE DisplayText LIKE @ADDRESS
					AND [Type_Id] = @AddressType_Id;
					
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_ADDRESS)
			END;

			IF @MANAGER IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT ClientID, @FilterType_MANAGER
				FROM 
					dbo.ClientTable
					INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
				WHERE ManagerID = @MANAGER AND STATUS = 1;
			
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_MANAGER)	
			END

			IF @CONTROL = 1 BEGIN
				INSERT INTO @IdByFilterType
				SELECT DISTINCT CC_ID_CLIENT, @FilterType_CONTROL
				FROM dbo.ClientControl
				WHERE CC_REMOVE_DATE IS NULL
					AND (CC_BEGIN IS NULL OR CC_BEGIN <= @CUR_DATE);
			
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_CONTROL)		
			END
		
			IF @DISCONNECT IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT ClientID, @FilterType_DISCONNECT
				FROM 
					(
						SELECT ClientID, MAX(DisconnectDate) AS DisconnectDate
						FROM dbo.ClientDisconnectView WITH(NOEXPAND)
						GROUP BY ClientID
					) AS o_O
				WHERE DisconnectDate >= @DISCONNECT;
				
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_DISCONNECT)
			END;

			IF @DISC_BEGIN IS NOT NULL OR @DISC_END IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT ClientID, @FilterType_DISCONNECT
				FROM
				(
					SELECT ClientID, MAX(DisconnectDate) AS DisconnectDate
					FROM dbo.ClientDisconnectView WITH(NOEXPAND)
					GROUP BY ClientID
				) AS o_O
				WHERE (DisconnectDate >= @DISC_BEGIN OR @DISC_BEGIN IS NULL)
					AND (DisconnectDate <= @DISC_END OR @DISC_END IS NULL);
					
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_DISCONNECT)
			END
							
			IF EXISTS (SELECT * FROM @UsedFilterTypes)
				INSERT @IDs ([Id])
				SELECT
					[Id] = D.[Id]
				FROM
				(
					SELECT
						[Id] = D.[Id]
					FROM    
					(
						SELECT DISTINCT [Id] = CD.[Id]
						FROM @IdByFilterType CD
					) D
					CROSS JOIN @UsedFilterTypes C
					LEFT JOIN @IdByFilterType CD ON CD.[Type] = C.[Type] AND CD.[Id] = D.[Id]
					GROUP BY D.[Id]
					HAVING Count(*) = Count(CD.[Id])
				) D
				INNER JOIN [dbo].[ClientList@Get?Read]() P ON P.[WCL_ID] = D.[Id]
			ELSE
				INSERT @IDs ([Id])
				SELECT WCL_ID
				FROM [dbo].[ClientList@Get?Read]()
		END
		ELSE
		BEGIN			
			INSERT INTO @search(WRD)
			SELECT DISTINCT '%' + Word + '%'
			FROM dbo.SplitString(@SIMPLE);
			
			IF @STATUS IS NOT NULL OR @SERVICE IS NOT NULL BEGIN
				INSERT INTO @IdByFilterType
				SELECT ClientID, @FilterType_COMMON
				FROM dbo.ClientTable
				WHERE (StatusID = @STATUS OR @STATUS IS NULL)
					AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
					AND STATUS = 1;
			
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_COMMON)		
			END;
				
			IF EXISTS(SELECT * FROM @search) BEGIN
				INSERT INTO @IdByFilterType
				SELECT ID_CLIENT, @FilterType_NAME
				FROM
				(
					SELECT ID_CLIENT
					FROM dbo.ClientIndex z WITH(NOLOCK)
					WHERE NOT EXISTS
						(
							SELECT * 
							FROM @search
							WHERE NOT (DATA LIKE WRD)
						)
				) AS C;
				
				INSERT INTO @UsedFilterTypes
				VALUES(@FilterType_NAME)
			END;
					
			IF EXISTS (SELECT * FROM @UsedFilterTypes)
				INSERT @IDs ([Id])
				SELECT
					[Id] = D.[Id]
				FROM
				(
					SELECT
						[Id] = D.[Id]
					FROM    
					(
						SELECT DISTINCT [Id] = CD.[Id]
						FROM @IdByFilterType CD
					) D
					CROSS JOIN @UsedFilterTypes C
					LEFT JOIN @IdByFilterType CD ON CD.[Type] = C.[Type] AND CD.[Id] = D.[Id]
					GROUP BY D.[Id]
					HAVING Count(*) = Count(CD.[Id])
				) D
				INNER JOIN [dbo].[ClientList@Get?Read]() P ON P.[WCL_ID] = D.[Id]
			ELSE
				INSERT @IDs ([Id])
				SELECT WCL_ID
				FROM [dbo].[ClientList@Get?Read]()
		END;

		INSERT INTO @WIDs
		SELECT WCL_ID
		FROM [dbo].[ClientList@Get?Write]() 

		SELECT 
			a.ClientID, 
			ClientFullName,
			NAMES AS ClientParallelName, 
			CONVERT(VARCHAR(255), DisplayText) AS ClientAdress,
			ClientServiceId,
			ServiceStatusIndex, OriClient,
				
			CONVERT(BIT, 0) AS ClientControl,
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
						WHERE z.ClientID = t.Id
					) THEN 1
				ELSE 0
			END) AS ClientRegError,
			CONVERT(BIT, 0) AS IPLock,
			(
				SELECT TOP 1 DATE
				FROM 
					dbo.ClientSeminarDateView z WITH(NOEXPAND)
				WHERE z.ID_CLIENT = t.Id
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
							AND a.ID_CLIENT = t.Id
							AND (NOTIFY IS NULL OR NOTIFY <= GETDATE())
							AND (
									a.RECEIVER = ORIGINAL_LOGIN()
									OR
									(c.PSEDO = 'MANAGER' AND IS_MEMBER('rl_control_manager') = 1 AND ID_CLIENT IN (SELECT Id FROM @WIDs))
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
		FROM 
			@IDs t
			INNER JOIN dbo.ClientTable a ON t.Id = a.ClientID
			INNER JOIN dbo.ServiceStatusTable d ON d.ServiceStatusID = a.StatusID 
			LEFT JOIN [Cache].[Client?Addresses] e ON a.ClientID = e.Id AND e.[Type_Id] = @AddressType_Id
			LEFT JOIN [Cache].[Client?Names] f ON f.Id = t.Id
			LEFT JOIN dbo.DayTable g ON g.DayID = a.DayID
		ORDER BY ClientFullName
		OPTION (RECOMPILE);
		
		SELECT @COUNT = COUNT(*), @PCOUNT = SUM(ClientNewsPaper), @BCOUNT = SUM(ClientMainBook)
		FROM @IDs
		INNER JOIN dbo.ClientTable ON Id = ClientID
		OPTION (RECOMPILE);
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
