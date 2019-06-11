USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Meeting].[CLIENT_MEETING_UPDATE]
	@ID				UNIQUEIDENTIFIER,
	@ASSIGNED		UNIQUEIDENTIFIER,
	@DATE			DATETIME,
	@ID_RESULT		UNIQUEIDENTIFIER,
	@ID_PERSONAL	UNIQUEIDENTIFIER,
	@NOTE			NVARCHAR(MAX),
	@TOTAL_RES		UNIQUEIDENTIFIER,
	@SUCCESS_RATE	TINYINT,
	@STATUS			UNIQUEIDENTIFIER,
	@STATUS_NOTE	NVARCHAR(MAX),
	@NEXT			SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		BEGIN TRAN ClientMeeting

		DECLARE @TBL TABLE (ID	UNIQUEIDENTIFIER)
		DECLARE @NEWID	UNIQUEIDENTIFIER		

		UPDATE Meeting.ClientMeeting
		SET DATE		=	@DATE, 
			ID_RESULT	=	@ID_RESULT, 			
			NOTE		=	@NOTE
		WHERE ID = @ID						
		
		DECLARE @OLD_RES	UNIQUEIDENTIFIER
		DECLARE @OLD_RATE	TINYINT
		DECLARE @OLD_STATUS	UNIQUEIDENTIFIER
		DECLARE @OLD_STATUS_NOTE	NVARCHAR(MAX)

		SELECT @OLD_RES = ID_RESULT, @OLD_RATE = SUCCESS_RATE, @OLD_STATUS = ID_STATUS, @OLD_STATUS_NOTE = STATUS_NOTE
		FROM Meeting.AssignedMeeting
		WHERE ID = @ASSIGNED

		DECLARE @COMPANY UNIQUEIDENTIFIER

		SELECT @COMPANY = ID_COMPANY
		FROM Meeting.AssignedMeeting
		WHERE ID = @ASSIGNED

		EXEC Client.CALL_DATE_CHANGE @COMPANY, @NEXT

		IF (ISNULL(@OLD_RES, '00000000-0000-0000-0000-000000000000') <> ISNULL(@TOTAL_RES, '00000000-0000-0000-0000-000000000000')) 
			OR (ISNULL(@OLD_RATE, 101) <> ISNULL(@SUCCESS_RATE, 101))
			OR (ISNULL(@OLD_STATUS, '00000000-0000-0000-0000-000000000000') <> ISNULL(@STATUS, '00000000-0000-0000-0000-000000000000'))
			OR (ISNULL(@OLD_STATUS_NOTE, '') <> ISNULL(@STATUS_NOTE, ''))
		BEGIN
			DELETE FROM @TBL

			INSERT INTO Meeting.AssignedMeeting(ID_MASTER, ID_COMPANY, ID_OFFICE, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, NOTE, ID_STATUS, STATUS_NOTE, ID_RESULT, SUCCESS_RATE, BDATE, UPD_USER)
				OUTPUT inserted.ID INTO @TBL
				SELECT ID, ID_COMPANY, ID_OFFICE, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, NOTE, ID_STATUS, STATUS_NOTE, ID_RESULT, SUCCESS_RATE, BDATE, UPD_USER
				FROM Meeting.AssignedMeeting
				WHERE ID = @ASSIGNED
			
			SELECT @NEWID = ID FROM @TBL

			INSERT INTO Meeting.MeetingAddress(ID_MEETING, ID_AREA, ID_STREET, HOME, ROOM, NOTE)
				SELECT @NEWID, ID_AREA, ID_STREET, HOME, ROOM, NOTE
				FROM Meeting.MeetingAddress
				WHERE ID_MEETING = @ASSIGNED

			UPDATE Meeting.AssignedMeeting
			SET	ID_RESULT		=	@TOTAL_RES,
				SUCCESS_RATE	=	@SUCCESS_RATE,
				ID_STATUS		=	@STATUS,
				STATUS_NOTE		=	@STATUS_NOTE,
				BDATE			=	GETDATE(),
				UPD_USER		=	ORIGINAL_LOGIN()
			WHERE ID = @ASSIGNED

			EXEC Client.COMPANY_REINDEX @COMPANY, NULL
		END

		COMMIT TRAN ClientMeeting
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN ClientMeeting

		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT 
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
