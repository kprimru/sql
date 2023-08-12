USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_DUTY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_DUTY_DELETE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_DUTY_DELETE]
	@ID	INT
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

		INSERT INTO dbo.ClientDutyTable(ID_MASTER, ClientID, ClientDutyDateTime, ClientDutyDate, ClientDutyTime, ClientDutyContact, ClientDutySurname, ClientDutyName, ClientDutyPatron, ClientDutyPos, ClientDutyPhone, DutyID, ManagerID, CallTypeID, ClientDutyQuest, ClientDutyDocs, ClientDutyNPO, ClientDutyComplete, ClientDutyComment, ClientDutyUncomplete, ClientDutyGive, ClientDutyAnswer, ClientDutyClaimDate, ClientDutyClaimNum, ClientDutyClaimAnswer, ClientDutyClaimComment, ID_GRANT_TYPE, CREATE_DATE, CREATE_USER, UPDATE_DATE, UPDATE_USER, STATUS, UPD_DATE, UPD_USER)
			SELECT @ID, ClientID, ClientDutyDateTime, ClientDutyDate, ClientDutyTime, ClientDutyContact, ClientDutySurname, ClientDutyName, ClientDutyPatron, ClientDutyPos, ClientDutyPhone, DutyID, ManagerID, CallTypeID, ClientDutyQuest, ClientDutyDocs, ClientDutyNPO, ClientDutyComplete, ClientDutyComment, ClientDutyUncomplete, ClientDutyGive, ClientDutyAnswer, ClientDutyClaimDate, ClientDutyClaimNum, ClientDutyClaimAnswer, ClientDutyClaimComment, ID_GRANT_TYPE, CREATE_DATE, CREATE_USER, UPDATE_DATE, UPDATE_USER, 2, UPD_DATE, UPD_USER
			FROM dbo.ClientDutyTable
			WHERE ClientDutyID = @ID

		UPDATE dbo.ClientDutyTable
		SET STATUS = 3,
			UPD_DATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ClientDutyID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DUTY_DELETE] TO rl_client_duty_d;
GO
