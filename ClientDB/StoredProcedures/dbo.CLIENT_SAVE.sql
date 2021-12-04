USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SAVE]
	@ID				Int			OUTPUT,
	@FULL			VarChar(250),
	@OFFICIAL		VarChar(500),
	@INN			VarChar(50),
	@SERVICE		Int,
	@STATUS			Int,
	@RANGE			Int,
	@PAY_TYPE		Int,
	@SERV_TYPE		Int,
	@CLIENT_KIND	SmallInt,
	@ORI			Bit,
	@ACTIVITY		VarChar(MAX),
	@PLACE			VarChar(MAX),
	@NOTE			VarChar(MAX),
	@DAY_BEGIN		VarChar(20),
	@DAY_END		VarChar(20),
	@DINNER_BEGIN	VarChar(20),
	@DINNER_END		VarChar(20),
	@VISIT_DAY		Int,
	@VISIT_TIME		DateTime,
	@VISIT_LEN		Int,
	@PAPPER			Int,
	@BOOK			Int,
	@EMAIL			VarChar(200),
	@PURCHASE		UniqueIdentifier,
	@HEAD			Int = NULL,
	@USR_CHECK		Bit = 1,
	@STT_CHECK		Bit = 1,
	@HST_CHECK		Bit = 1,
	@INET_CHECK		Bit = 1,
	@IsLarge		Bit = 0,
	@IsDebtor		Bit = 0,
	@VISIT_COUNT	SmallInt = NULL,
	@RestrictionsData    VarChar(Max) = NULL
WITH EXECUTE AS OWNER
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

		IF @ID IS NULL
		BEGIN
			INSERT INTO dbo.ClientTable(
					ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
					StatusID, RangeID, PayTypeID, ServiceTypeID, ClientKind_Id,
					OriClient, ClientActivity, ClientPlace, ClientNote,
					ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd,
					DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook,
					ClientEmail, PurchaseTypeID, ID_HEAD, USR_CHECK, STT_CHECK, HST_CHECK, INET_CHECK,
					ClientVisitCountID, IsLarge, IsDebtor)
				VALUES (
					@FULL, @OFFICIAL, @INN, @SERVICE,
					@STATUS, @RANGE, @PAY_TYPE, @SERV_TYPE, @CLIENT_KIND,
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
					ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
					StatusID, RangeID, PayTypeID, ServiceTypeID, ClientKind_Id,
					OriClient, ClientActivity, ClientPlace, ClientNote,
					ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd,
					DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook,
					ClientEmail, PurchaseTypeID, ID_HEAD, USR_CHECK, STT_CHECK, HST_CHECK, INET_CHECK,
					ClientVisitCountID, IsLarge, IsDebtor, ClientTypeId, ClientLast, UPD_USER)
				SELECT
					@ID, 2,
					ClientFullName, ClientOfficial, ClientINN, ClientServiceID,
					StatusID, RangeID, PayTypeID, ServiceTypeID, ClientKind_Id,
					OriClient, ClientActivity, ClientPlace, ClientNote,
					ClientDayBegin, ClientDayEnd, DinnerBegin, DinnerEnd,
					DayID, ServiceStart, ServiceTime, ClientNewspaper, ClientMainBook,
					ClientEmail, PurchaseTypeID, ID_HEAD, USR_CHECK, STT_CHECK, HST_CHECK, INET_CHECK,
					ClientVisitCountID, IsLarge, IsDebtor, ClientTypeId, ClientLast, UPD_USER
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
			SET ClientFullName			=	@FULL,
				ClientOfficial			=	@OFFICIAL,
				ClientINN				=	@INN,
				/*ClientServiceID		=	@SERVICE,*/
				StatusID				=	ISNULL(@STATUS, StatusID),
				RangeID					=	@RANGE,
				PayTypeID				=	@PAY_TYPE,
				ServiceTypeID			=	@SERV_TYPE,
				ClientKind_Id			=	@CLIENT_KIND,
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

		EXEC [dbo].[Client:Restrictions@Save]
            @Client_Id  = @Id,
            @Data       = @RestrictionsData;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SAVE] TO rl_client_save;
GO
