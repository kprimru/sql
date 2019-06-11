USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_FILES_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@COMPANY	UNIQUEIDENTIFIER,
	@FILE_NAME	NVARCHAR(512),
	@FILE_DATA	VARBINARY(MAX),
	@NOTE		NVARCHAR(MAX)	
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY	
		BEGIN TRAN CompanyFile

		INSERT INTO Client.CompanyFiles(ID_MASTER, ID_COMPANY, FILE_NAME, FILE_DATA, FILE_NOTE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID, ID_COMPANY, FILE_NAME, FILE_DATA, FILE_NOTE, 2, BDATE, EDATE, UPD_USER
			FROM Client.CompanyFiles
			WHERE ID = @ID
	
		UPDATE Client.CompanyFiles
		SET FILE_NOTE = @NOTE,
			BDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID		
		
		--EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN CompanyFile
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN CompanyFile

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
