USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[ASSIGNED_MEETING_CANCEL]
	@ID					UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		BEGIN TRAN Meeting

		DECLARE @TBL TABLE (ID	UNIQUEIDENTIFIER)

		INSERT INTO Meeting.AssignedMeeting(ID_MASTER, ID_COMPANY, ID_OFFICE, ID_CALL, ID_ASSIGNER, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, NOTE, INCOMING, SPECIFY, ID_RESULT, SUCCESS_RATE, STATUS, BDATE, EDATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_COMPANY, ID_OFFICE, ID_CALL, ID_ASSIGNER, ID_PERSONAL, COMPANY_PERSONAL, EXPECTED_DATE, NOTE, INCOMING, SPECIFY, ID_RESULT, SUCCESS_RATE, 2, BDATE, EDATE, UPD_USER
			FROM Meeting.AssignedMeeting
			WHERE ID = @ID

		DECLARE @NEWID	UNIQUEIDENTIFIER

		SELECT @NEWID = ID FROM @TBL

		INSERT INTO Meeting.MeetingAddress(ID_MEETING, ID_AREA, ID_STREET, HOME, ROOM, NOTE)
			SELECT @NEWID, ID_AREA, ID_STREET, HOME, ROOM, NOTE
			FROM Meeting.MeetingAddress
			WHERE ID_MEETING = @ID

		SELECT * FROM Meeting.MeetingStatus

		UPDATE Meeting.AssignedMeeting
		SET ID_STATUS	=	(SELECT ID FROM Meeting.MeetingStatus WHERE STATUS = 4),
			BDATE		=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE	ID	=	@ID

		/*
		DECLARE @CO_XML NVARCHAR(MAX)
		DECLARE @MANAGER	UNIQUEIDENTIFIER

		SET @CO_XML = N'<root><item id="' + CONVERT(NVARCHAR(50), @COMPANY) + '" /></root>'

		IF @PERSONAL IS NOT NULL
		BEGIN
			SELECT @MANAGER = MANAGER FROM Personal.OfficePersonal WHERE ID = @PERSONAL
			IF (SELECT ID_PERSONAL FROM Client.CompanyProcessSaleView WITH(NOEXPAND) WHERE ID = @COMPANY) <> @PERSONAL
			BEGIN
				EXEC Client.COMPANY_PROCESS_SALE_RETURN @CO_XML
				EXEC Client.COMPANY_PROCESS_SALE @CO_XML, @PERSONAL

				IF (SELECT MANAGER FROM Personal.OfficePersonal WHERE ID = @PERSONAL) <> (SELECT ID_PERSONAL FROM Client.CompanyProcessManagerView WITH(NOEXPAND) WHERE ID = @COMPANY)
				BEGIN
					IF @MANAGER IS NOT NULL
					BEGIN
						EXEC Client.COMPANY_PROCESS_MANAGER_RETURN @CO_XML
						EXEC Client.COMPANY_PROCESS_MANAGER @CO_XML, @MANAGER
					END
				END
			END
		END
		*/

		COMMIT TRAN Meeting
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN Meeting

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

GO
GRANT EXECUTE ON [Meeting].[ASSIGNED_MEETING_CANCEL] TO rl_meeting_cancel;
GO
