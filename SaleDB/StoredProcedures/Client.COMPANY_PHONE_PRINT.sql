USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_PHONE_PRINT]
	@ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			PHONE, NOTE, b.NAME AS PH_NAME, c.NAME AS OF_NAME
		FROM	
			Client.CompanyPhone a
			LEFT OUTER JOIN Client.PhoneType b ON b.ID = a.ID_TYPE
			LEFT OUTER JOIN Client.Office c ON c.ID = a.ID_OFFICE
		WHERE a.ID_COMPANY = @ID AND a.STATUS = 1
		ORDER BY c.NAME, b.NAME, PHONE
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