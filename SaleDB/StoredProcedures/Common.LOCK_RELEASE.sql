USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[LOCK_RELEASE]
	@ID		NVARCHAR(MAX),
	@DATA	VARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		DELETE
		FROM Common.Locks		
		WHERE DATA = @DATA 
			AND REC IN 
				(
					SELECT ID
					FROM Common.TableStringFromXML(@ID)
				)	
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