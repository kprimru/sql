USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_LIST_PRINT]
	@LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY		
		SELECT 
			b.NUMBER, b.NAME,
			REVERSE(STUFF(REVERSE(
				(
					SELECT y.NAME + ', '
					FROM 
						Client.CompanyActivity z
						INNER JOIN Client.Activity y ON z.ID_ACTIVITY = y.ID
					WHERE z.ID_COMPANY = b.ID
					ORDER BY y.NAME FOR XML PATH('')
				)
			), 1, 2, '')) AS ACTIVITY,
			REVERSE(STUFF(REVERSE(
				(
					SELECT LTRIM(RTRIM(z.PHONE)) + CASE WHEN ISNULL(NOTE, '') <> '' THEN '(' +  NOTE + ')' ELSE '' END  + ', '
					FROM 
						Client.CompanyPhone z
					WHERE z.STATUS = 1
						AND z.ID_COMPANY = b.ID
					ORDER BY PHONE FOR XML PATH('')
				)
			), 1, 2, ''))  AS PHONES,
			REVERSE(STUFF(REVERSE(
				(
					SELECT 
						FIO + ISNULL('/' + x.NAME, '') + CASE WHEN ISNULL(NOTE, '') <> '' THEN ' (' + NOTE + ')' ELSE '' END + 
						'  телефон: ' + 
						ISNULL(REVERSE(STUFF(REVERSE(
							(
								SELECT LTRIM(RTRIM(y.PHONE)) + ', '
								FROM
									Client.CompanyPersonalPhone y
								WHERE y.ID_PERSONAL = z.ID
								ORDER BY PHONE FOR XML PATH('')
							)
						), 1, 2, '')), '') + '; '
					FROM 
						Client.CompanyPersonal z
						LEFT OUTER JOIN Client.Position x ON z.ID_POSITION = x.ID
					WHERE z.STATUS = 1
						AND z.ID_COMPANY = b.ID
					ORDER BY FIO FOR XML PATH('')
				)
			), 1, 2, ''))  AS PERSONAL
		FROM 		
			Common.TableGUIDFromXML(@LIST) a
			INNER JOIN Client.Company b ON a.ID = b.ID
		ORDER BY NAME
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyControl

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
