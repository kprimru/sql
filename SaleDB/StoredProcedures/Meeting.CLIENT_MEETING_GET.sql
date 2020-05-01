USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meeting].[CLIENT_MEETING_GET]
	@ID			UNIQUEIDENTIFIER,
	@ASSIGNED	UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @ID IS NOT NULL
			SELECT
				ID, DATE, ID_PERSONAL, ID_RESULT, NOTE,
				(
					SELECT TOP 1 SUCCESS_RATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS SUCCESS_RATE,
				(
					SELECT TOP 1 a.ID_RESULT
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_RES,
				(
					SELECT TOP 1 a.ID_STATUS
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS,
				(
					SELECT TOP 1 a.STATUS_NOTE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS_NOTE,
				(
					SELECT DATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Client.CallDate z ON z.ID_COMPANY = a.ID_COMPANY
					WHERE a.ID = @ASSIGNED
				) AS NEXT_DATE
			FROM
				Meeting.ClientMeeting t
			WHERE ID = @ID
		ELSE
			SELECT
				CONVERT(UNIQUEIDENTIFIER, NULL) AS ID,
				Common.DateOf(GETDATE()) AS DATE,
				CONVERT(UNIQUEIDENTIFIER, NULL) AS ID_PERSONAL,
				CONVERT(UNIQUEIDENTIFIER, NULL)ID_RESULT,
				CONVERT(NVARCHAR(MAX), '') AS NOTE,
				(
					SELECT TOP 1 SUCCESS_RATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS SUCCESS_RATE,
				(
					SELECT TOP 1 a.ID_RESULT
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_RES,
				(
					SELECT TOP 1 a.ID_STATUS
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS,
				(
					SELECT TOP 1 a.STATUS_NOTE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Meeting.ClientMeeting b ON a.ID = b.ID_ASSIGNED
					WHERE a.ID = @ASSIGNED AND a.ID_MASTER IS NULL
				) AS TOTAL_STATUS_NOTE,
				(
					SELECT DATE
					FROM
						Meeting.AssignedMeeting a
						INNER JOIN Client.CallDate z ON z.ID_COMPANY = a.ID_COMPANY
					WHERE a.ID = @ASSIGNED
				) AS NEXT_DATE
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
GRANT EXECUTE ON [Meeting].[CLIENT_MEETING_GET] TO rl_meeting_r;
GRANT EXECUTE ON [Meeting].[CLIENT_MEETING_GET] TO rl_meeting_result;
GO