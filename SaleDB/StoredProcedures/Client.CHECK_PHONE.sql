USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[CHECK_PHONE]
	@COMPANY	UNIQUEIDENTIFIER,
	@PHONE		NVARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PHONE_LIST NVARCHAR(MAX)

	IF @COMPANY IS NULL
	BEGIN
		SELECT @PHONE_LIST = 
			(
				SELECT GR_NAME + ': ' + ISNULL(CONVERT(VARCHAR(20), NUMBER), '') + CASE WHEN ISNULL(SHORT, '') = '' THEN '' ELSE '(' + SHORT + ')' END + CHAR(10) 
				FROM 
					(
						SELECT 'Компания' AS GR_NAME, b.NUMBER, b.SHORT
						FROM 
							Client.CompanyPhone a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE a.STATUS = 1 AND b.STATUS = 1
							AND a.PHONE_S = @PHONE
							
						UNION 
						
						SELECT 'Сотрудник', b.NUMBER, b.SHORT
						FROM 
							Client.CompanyPersonal a
							INNER JOIN Client.CompanyPersonalPhone c ON a.ID = c.ID_PERSONAL
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE a.STATUS = 1 AND b.STATUS = 1
							AND c.PHONE_S = @PHONE
					) AS o_O
				ORDER BY NUMBER FOR XML PATH('')
			)
	END
	ELSE
	BEGIN
		SELECT @PHONE_LIST = 
			(
				SELECT GR_NAME + ': ' + ISNULL(CONVERT(VARCHAR(20), NUMBER), '') + CASE WHEN ISNULL(SHORT, '') = '' THEN '' ELSE '(' + SHORT + ')' END + CHAR(10) 
				FROM 
					(
						SELECT 'Компания' AS GR_NAME, b.NUMBER, b.SHORT
						FROM 
							Client.CompanyPhone a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE a.STATUS = 1 AND b.STATUS = 1
							AND a.PHONE_S = @PHONE
							AND b.ID <> @COMPANY
							
						UNION 
						
						SELECT 'Сотрудник', b.NUMBER, b.SHORT
						FROM 
							Client.CompanyPersonal a
							INNER JOIN Client.CompanyPersonalPhone c ON a.ID = c.ID_PERSONAL
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
						WHERE a.STATUS = 1 AND b.STATUS = 1
							AND c.PHONE_S = @PHONE
							AND b.ID <> @COMPANY
					) AS o_O
				ORDER BY NUMBER FOR XML PATH('')
			)
	END
	
	SELECT @PHONE_LIST AS PHONE_LIST
END
