USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[COMPANY_CALL_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@DEL	BIT = 0,
	@RC		INT = NULL OUTPUT,
	@CONTROL	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		SELECT 
			a.ID, b.SHORT, b.NAME, CL_PERSONAL, c.SHORT AS PER_SHORT, DATE, NOTE,
			CONVERT(BIT, 
				(
					SELECT COUNT(*)
					FROM Meeting.AssignedMeeting
					WHERE ID_CALL = @ID
				)
			) AS CALL_MEETING,
			a.STATUS,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM 
					(
						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2
	
						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID = a.ID
							AND z.STATUS = 1						
					) AS o_O
				ORDER BY BDATE
			) AS CREATE_DATA,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM 
					(
						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2
	
						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.Call z
						WHERE z.ID = a.ID
							AND z.STATUS = 1						
					) AS o_O
				ORDER BY BDATE DESC
			) AS UPDATE_DATA,
			CASE a.STATUS
				WHEN 3 THEN CONVERT(VARCHAR(20), a.EDATE, 104) + ' ' + CONVERT(VARCHAR(20), a.EDATE, 108) + '/' + a.UPD_USER
				ELSE ''
			END AS DELETE_DATA
		FROM 
			Client.Call a
			INNER JOIN Personal.OfficePersonal c ON c.ID = a.ID_PERSONAL
			LEFT OUTER JOIN Client.Office b ON a.ID_OFFICE = b.ID
		WHERE a.ID_COMPANY = @ID 
			AND (a.STATUS = 1 OR a.STATUS = 3 AND @DEL = 1)
			AND (@CONTROL = 0 OR CONTROL = 1 AND @CONTROL = 1 OR @CONTROL IS NULL)
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