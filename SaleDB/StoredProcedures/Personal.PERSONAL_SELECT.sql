USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Personal].[PERSONAL_SELECT]
	@FILTER		NVARCHAR(256),
	@DISMISS	BIT,
	@RC		INT	= NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		SELECT
			a.ID, 
			ISNULL(a.SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(a.PATRON + ' ', '') AS FULL_NAME,
			a.SHORT, a.SURNAME, a.NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT b.SHORT + ', '
					FROM 
						Personal.PersonalType b
						INNER JOIN Personal.OfficePersonalType d ON d.ID_TYPE = b.ID
					WHERE d.ID_PERSONAL = a.ID AND d.EDATE IS NULL
					ORDER BY b.NAME FOR XML PATH('')
				)), 1, 2, '')) AS TP_NAME, 
			c.SHORT AS MAN_NAME,
			a.START_DATE, a.END_DATE,
			e.principal_id AS US_ID, f.principal_id AS LG_ID
		FROM	
			Personal.OfficePersonal a			
			LEFT OUTER JOIN Personal.OfficePersonal c ON a.MANAGER = c.ID
			LEFT OUTER JOIN sys.database_principals e ON e.name = a.login AND e.type IN ('U', 'S')
			LEFT OUTER JOIN sys.server_principals f ON f.name = a.login AND f.type IN ('U', 'S')
		WHERE a.END_DATE IS NULL
			AND
				(
					@FILTER IS NULL
					OR (a.NAME LIKE @FILTER)
					OR (a.SURNAME LIKE @FILTER)
					OR (a.PATRON LIKE @FILTER)
					OR (a.SHORT LIKE @FILTER)
				)

		UNION ALL

		SELECT
			a.ID, 
			ISNULL(a.SURNAME + ' ', '') + ISNULL(a.NAME + ' ', '') + ISNULL(a.PATRON + ' ', '') AS FULL_NAME,
			a.SHORT, a.SURNAME, a.NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT b.NAME + ', '
					FROM 
						Personal.PersonalType b
						INNER JOIN Personal.OfficePersonalType d ON d.ID_TYPE = b.ID
					WHERE d.ID_PERSONAL = a.ID AND d.EDATE IS NULL
					ORDER BY b.NAME FOR XML PATH('')
				)), 1, 2, '')) AS TP_NAME, 
			c.SHORT AS MAN_NAME,
			a.START_DATE, a.END_DATE,
			e.principal_id AS US_ID, f.principal_id AS LG_ID
		FROM	
			Personal.OfficePersonal a			
			LEFT OUTER JOIN Personal.OfficePersonal c ON a.MANAGER = c.ID
			LEFT OUTER JOIN sys.database_principals e ON e.name = a.login AND e.type IN ('U', 'S')
			LEFT OUTER JOIN sys.server_principals f ON f.name = a.login AND f.type IN ('U', 'S')
		WHERE a.END_DATE IS NOT NULL AND @DISMISS = 1
			AND
				(
					@FILTER IS NULL
					OR (a.NAME LIKE @FILTER)
					OR (a.SURNAME LIKE @FILTER)
					OR (a.PATRON LIKE @FILTER)
					OR (a.SHORT LIKE @FILTER)
				)
		ORDER BY a.SHORT

		SET @RC = @@ROWCOUNT
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