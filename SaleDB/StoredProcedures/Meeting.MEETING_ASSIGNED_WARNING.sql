USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[MEETING_ASSIGNED_WARNING]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT b.ID, b.NAME, b.NUMBER, a.EXPECTED_DATE, c.SHORT, d.NAME
		FROM
			Meeting.AssignedMeeting a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_ASSIGNER
			LEFT OUTER JOIN Meeting.MeetingStatus d ON d.ID = a.ID_STATUS
		WHERE b.STATUS = 1 --AND a.ID_PERSONAL IS NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM Meeting.AssignedMeetingPersonal z
					WHERE z.ID_MEETING = a.ID
				)
			AND a.STATUS = 1
			AND a.ID_MASTER IS NULL
			AND a.ID_PARENT IS NULL
			AND (d.STATUS IS NULL OR d.STATUS IN (0, 3))
	END TRY
	BEGIN CATCH
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
GRANT EXECUTE ON [Meeting].[MEETING_ASSIGNED_WARNING] TO rl_warning_meeting_assigned;
GO