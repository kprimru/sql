USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DUTY_INSERT]
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
	@ID	INT = NULL OUTPUT,
	@CLAIM_DATE	SMALLDATETIME = NULL,
	@CLAIM_NUM	VARCHAR(50) = NULL,
	@CLAIM_ANSWER	SMALLDATETIME = NULL,
	@CLAIM_COMMENT	VARCHAR(500) = NULL,
	@GRANT_TYPE	UNIQUEIDENTIFIER = NULL,
	@SURNAME	VARCHAR(150) = NULL,
	@NAME		VARCHAR(150) = NULL,
	@PATRON		VARCHAR(150) = NULL,
	@DIRECTION	UNIQUEIDENTIFIER = NULL,
	@EMAIL	NVARCHAR(128) = NULL,
	@LINK	BIT = NULL
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

		INSERT INTO dbo.ClientDutyTable(
					ClientID, ClientDutyDateTime,
					ClientDutyContact,
					ClientDutySurname, ClientDutyName, ClientDutyPatron,
					ClientDutyPos, ClientDutyPhone,
					DutyID, CallTypeID,
					ClientDutyQuest, ClientDutyDocs, ClientDutyNPO,
					ClientDutyComplete, ClientDutyComment,
					ClientDutyUncomplete, ClientDutyGive, ClientDutyAnswer,
					ClientDutyClaimDate, ClientDutyClaimNum,
					ClientDutyClaimAnswer, ClientDutyClaimComment, ID_GRANT_TYPE, ID_DIRECTION, EMAIL, LINK)
			VALUES(@CLIENT, @DT, @CONTACT, @SURNAME, @NAME, @PATRON, @POS, @PHONE, @DUTY, @CALL_TYPE,
					@QUEST, @DOCS, @NPO, @COMPLETE, @COMMENT, @UNCOMPLETE, @GIVE, @ANSWER,
					@CLAIM_DATE, @CLAIM_NUM, @CLAIM_ANSWER, @CLAIM_COMMENT, @GRANT_TYPE, @DIRECTION, @EMAIL, @LINK)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC dbo.CLIENT_DUTY_IB_PROCESS @ID, @IB

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_INSERT] TO rl_client_duty_i;
GO