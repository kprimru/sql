USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Meeting].[CLIENT_MEETING_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@RC		INT				=	NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		SELECT a.ID, DATE, c.SHORT, b.NAME, NOTE
		FROM 
			Meeting.ClientMeeting a
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_PERSONAL
			LEFT OUTER JOIN Meeting.MeetingResult b ON a.ID_RESULT = b.ID			
		WHERE ID_ASSIGNED = @ID
		ORDER BY DATE DESC

		SELECT @RC = @@ROWCOUNT
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