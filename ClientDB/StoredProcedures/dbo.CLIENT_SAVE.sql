USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_SAVE]
	@ID				INT OUTPUT,
	@SHORT			VARCHAR(100),
	@FULL			VARCHAR(250),
	@OFFICIAL		VARCHAR(500),
	@INN			VARCHAR(50),
	@SERVICE		INT,
	@STATUS			INT,
	@RANGE			INT,
	@PAY_TYPE		INT,
	@SERV_TYPE		INT,
	@CLIENT_TYPE	INT,
	@ORI			BIT,
	@ACTIVITY		VARCHAR(150),
	@PLACE			VARCHAR(MAX),
	@NOTE			VARCHAR(MAX),
	@DAY_BEGIN		VARCHAR(20),
	@DAY_END		VARCHAR(20),
	@DINNER_BEGIN	VARCHAR(20),
	@DINNER_END		VARCHAR(20),
	@VISIT_DAY		INT,
	@VISIT_TIME		DATETIME,
	@VISIT_LEN		INT,
	@PAPPER			INT,
	@BOOK			INT,
	@EMAIL			VARCHAR(200),
	@PURCHASE		UNIQUEIDENTIFIER,
	@HEAD			INT = NULL,
	@USR_CHECK		BIT = 1,
	@STT_CHECK		BIT = 1,
	@HST_CHECK		BIT = 1,
	@INET_CHECK		BIT = 1,
	@IsLarge		BIT = 0,
	@IsDebtor		BIT = 0,
	@VISIT_COUNT	SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN			
		INSERT INTO dbo.ClientTable(
				ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
				StatusID, RangeID, PayTypeID, ServiceTypeID, ClientContractTypeID, 
				OriClient, ClientActivity, ClientPlace, ClientNote, 
				ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd, 
				DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook, 
				ClientEmail, PurchaseTypeID, ID_HEAD, USR_CHECK, STT_CHECK, HST_CHECK, INET_CHECK,
				ClientVisitCountID, IsLarge, IsDebtor)
			VALUES (
				@SHORT, @FULL, @OFFICIAL, @INN, @SERVICE,
				@STATUS, @RANGE, @PAY_TYPE, @SERV_TYPE, @CLIENT_TYPE,
				@ORI, @ACTIVITY, @PLACE, @NOTE, 
				@DAY_BEGIN, @DAY_END, @DINNER_BEGIN, @DINNER_END,
				@VISIT_DAY, @VISIT_TIME, @VISIT_LEN, @PAPPER, @BOOK, 
				@EMAIL, @PURCHASE, @HEAD, @USR_CHECK, @STT_CHECK, @HST_CHECK, @INET_CHECK,
				@VISIT_COUNT, @IsLarge, @IsDebtor
			)
			
		SELECT @ID = SCOPE_IDENTITY()
		
		UPDATE dbo.ClientTable
		SET ID_MASTER = @ID
		WHERE ClientID = @ID
		
		INSERT INTO dbo.ClientService(ID_CLIENT, ID_SERVICE, DATE, MANAGER)
			SELECT @ID, @SERVICE, dbo.DateOf(GETDATE()), ManagerName
			FROM 
				dbo.ServiceTable a
				INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
			WHERE ServiceID = @SERVICE
			
		IF (SELECT Maintenance.GlobalClientAutoClaim()) = 1
		BEGIN			
			INSERT INTO dbo.ClientStudyClaim(ID_CLIENT, DATE, NOTE, REPEAT, UPD_USER)
				SELECT @ID, dbo.Dateof(GETDATE()), 'Новый клиент', 0, 'Автомат'
		END
			
		EXEC dbo.CLIENT_REINDEX @ID, NULL
	END
	ELSE
	BEGIN
		DECLARE @NEW INT
		
		INSERT INTO dbo.ClientTable(
				ID_MASTER, STATUS,
				ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
				StatusID, RangeID, PayTypeID, ServiceTypeID, ClientContractTypeID, 
				OriClient, ClientActivity, ClientPlace, ClientNote, 
				ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd, 
				DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook, 
				ClientEmail, PurchaseTypeID, ID_HEAD, USR_CHECK, STT_CHECK, HST_CHECK, INET_CHECK, 
				ClientVisitCountID, IsLarge, IsDebtor, ClientLast, UPD_USER)
			SELECT
				@ID, 2,
				ClientShortName, ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
				StatusID, RangeID, PayTypeID, ServiceTypeID, ClientContractTypeID, 
				OriClient, ClientActivity, ClientPlace, ClientNote, 
				ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd, 
				DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook, 
				ClientEmail, PurchaseTypeID, ID_HEAD, USR_CHECK, STT_CHECK, HST_CHECK, INET_CHECK, 
				ClientVisitCountID, IsLarge, IsDebtor, ClientLast, UPD_USER
			FROM dbo.ClientTable
			WHERE ClientID = @ID
			
		SELECT @NEW = SCOPE_IDENTITY()
			
		UPDATE dbo.ClientAddress
		SET CA_ID_CLIENT = @NEW
		WHERE CA_ID_CLIENT = @ID
		
		UPDATE dbo.ClientPersonal
		SET CP_ID_CLIENT = @NEW
		WHERE CP_ID_CLIENT = @ID
		
		UPDATE dbo.ClientNames
		SET ID_CLIENT = @NEW
		WHERE ID_CLIENT = @ID
			
		IF (
				SELECT ServiceStatusReg
				FROM dbo.ServiceStatusTable
				WHERE ServiceStatusID = @STATUS
			) <> 
			(
				SELECT ServiceStatusReg
				FROM 
					dbo.ServiceStatusTable
					INNER JOIN dbo.ClientTable ON StatusID = ServiceStatusID
				WHERE ClientID = @ID AND STATUS = 1
			)
		BEGIN
			/* кто-то уже отключил/подключил систему. Не трогаем статус*/
			SET @STATUS = NULL
		END
			
		UPDATE dbo.ClientTable
		SET ClientShortName			=	@SHORT,
			ClientFullName			=	@FULL,
			ClientOfficial			=	@OFFICIAL,
			ClientINN				=	@INN,
			/*ClientServiceID		=	@SERVICE,*/
			StatusID				=	ISNULL(@STATUS, StatusID),
			RangeID					=	@RANGE,
			PayTypeID				=	@PAY_TYPE,
			ServiceTypeID			=	@SERV_TYPE,
			ClientContractTypeID	=	@CLIENT_TYPE,
			OriClient				=	@ORI,
			ClientActivity			=	@ACTIVITY,
			ClientPlace				=	@PLACE,
			ClientNote				=	@NOTE,
			ClientDayBegin			=	@DAY_BEGIN,
			ClientDayEnd			=	@DAY_END,
			DinnerBegin				=	@DINNER_BEGIN,
			DinnerEnd				=	@DINNER_END,
			DayID					=	@VISIT_DAY,
			ServiceStart			=	@VISIT_TIME,
			ServiceTime				=	@VISIT_LEN,
			ClientNewspaper			=	@PAPPER,
			ClientMainBook			=	@BOOK,
			ClientEmail				=	@EMAIL,
			PurchaseTypeID			=	@PURCHASE,
			ID_HEAD					=	@HEAD,
			USR_CHECK				=	@USR_CHECK,
			STT_CHECK				=	@STT_CHECK,
			HST_CHECK				=	@HST_CHECK,
			INET_CHECK				=	@INET_CHECK,
			IsLarge					=	@IsLarge,
			IsDebtor				=	@IsDebtor,
			ClientVisitCountID		=	@VISIT_COUNT,
			ClientLast				=	GETDATE(),
			UPD_USER				=	ORIGINAL_LOGIN()
		WHERE ClientID = @ID
	END
END