USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DUTY_UPDATE]
	@ID	INT,
	@CLIENT	INT,
	@DT	DATETIME,
	@CONTACT	VARCHAR(150),
	@POS	VARCHAR(50),
	@PHONE	VARCHAR(50),
	@DUTY	INT,
	@CALL_TYPE	INT,
	@QUEST	VARCHAR(MAX),
	@DOCS	INT,
	@NPO	BIT,
	@COMPLETE	BIT,
	@COMMENT	VARCHAR(MAX),
	@UNCOMPLETE	BIT,
	@GIVE	VARCHAR(100),
	@ANSWER	DATETIME,
	@IB	VARCHAR(MAX),
	@CLAIM_DATE SMALLDATETIME = NULL, 
	@CLAIM_NUM VARCHAR(50) = NULL, 
	@CLAIM_ANSWER SMALLDATETIME = NULL, 
	@CLAIM_COMMENT VARCHAR(500) = NULL,
	@GRANT_TYPE	UNIQUEIDENTIFIER = NULL,
	@SURNAME	VARCHAR(150),
	@NAME		VARCHAR(150),
	@PATRON		VARCHAR(150),
	@DIRECTION	UNIQUEIDENTIFIER = NULL,
	@EMAIL	NVARCHAR(128) = NULL,
	@LINK	BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientDutyTable(ID_MASTER, ClientID, ClientDutyDateTime, ClientDutyDate, ClientDutyTime, ClientDutyContact, ClientDutySurname, ClientDutyName, ClientDutyPatron, ClientDutyPos, ClientDutyPhone, DutyID, ManagerID, CallTypeID, ClientDutyQuest, ClientDutyDocs, ClientDutyNPO, ClientDutyComplete, ClientDutyComment, ClientDutyUncomplete, ClientDutyGive, ClientDutyAnswer, ClientDutyClaimDate, ClientDutyClaimNum, ClientDutyClaimAnswer, ClientDutyClaimComment, ID_GRANT_TYPE, CREATE_DATE, CREATE_USER, UPDATE_DATE, UPDATE_USER, STATUS, UPD_DATE, UPD_USER, ID_DIRECTION, EMAIL, LINK)
		SELECT @ID, ClientID, ClientDutyDateTime, ClientDutyDate, ClientDutyTime, ClientDutyContact, ClientDutySurname, ClientDutyName, ClientDutyPatron, ClientDutyPos, ClientDutyPhone, DutyID, ManagerID, CallTypeID, ClientDutyQuest, ClientDutyDocs, ClientDutyNPO, ClientDutyComplete, ClientDutyComment, ClientDutyUncomplete, ClientDutyGive, ClientDutyAnswer, ClientDutyClaimDate, ClientDutyClaimNum, ClientDutyClaimAnswer, ClientDutyClaimComment, ID_GRANT_TYPE, CREATE_DATE, CREATE_USER, UPDATE_DATE, UPDATE_USER, 2, UPD_DATE, UPD_USER, ID_DIRECTION, EMAIL, LINK
		FROM dbo.ClientDutyTable
		WHERE ClientDutyID = @ID
	
	UPDATE dbo.ClientDutyTable
	SET	ClientDutyDateTime = @DT, 
		ClientDutyContact = @CONTACT, 
		ClientDutySurname = @SURNAME,
		ClientDutyName = @NAME,
		ClientDutyPatron = @PATRON,
		ClientDutyPos = @POS, 
		ClientDutyPhone = @PHONE, 
		DutyID = @DUTY, 
		CallTypeID = @CALL_TYPE, 
		ClientDutyQuest = @QUEST, 
		ClientDutyDocs = @DOCS, 
		ClientDutyNPO = @NPO, 
		ClientDutyComplete = @COMPLETE, 
		ClientDutyComment = @COMMENT, 
		ClientDutyUncomplete = @UNCOMPLETE, 
		ClientDutyGive = @GIVE,
		ClientDutyAnswer = @ANSWER,
		ClientDutyClaimDate = @CLAIM_DATE, 
		ClientDutyClaimNum = @CLAIM_NUM, 
		ClientDutyClaimAnswer = @CLAIM_ANSWER, 
		ClientDutyClaimComment = @CLAIM_COMMENT,
		ID_GRANT_TYPE = @GRANT_TYPE,		
		UPDATE_DATE = GETDATE(),
		UPDATE_USER = ORIGINAL_LOGIN(),
		UPD_DATE = GETDATE(),
		UPD_USER = ORIGINAL_LOGIN(),
		ID_DIRECTION = @DIRECTION,
		EMAIL = @EMAIL,
		LINK	=	@LINK
	WHERE ClientDutyID = @ID

		
	EXEC dbo.CLIENT_DUTY_IB_PROCESS @ID, @IB
END