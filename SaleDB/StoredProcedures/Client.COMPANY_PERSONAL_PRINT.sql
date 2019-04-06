USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_PERSONAL_PRINT]
	@ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			FIO, b.NAME AS POS_NAME, a.NOTE AS PER_NOTE, d.NAME AS PT_NAME, PHONE, c.NOTE AS PH_NOTE, a.EMAIL
		FROM	
			Client.CompanyPersonal a
			LEFT OUTER JOIN Client.Position b ON a.ID_POSITION = b.ID
			LEFT OUTER JOIN Client.CompanyPersonalPhone c ON c.ID_PERSONAL = a.ID
			LEFT OUTER JOIN Client.PhoneType d ON d.ID = c.ID_TYPE
		WHERE a.ID_COMPANY = @ID
		ORDER BY a.FIO, d.NAME, c.PHONE
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