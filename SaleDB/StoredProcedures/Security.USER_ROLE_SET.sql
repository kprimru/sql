USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[USER_ROLE_SET]
	@USER	NVARCHAR(128),
	@ROLE	NVARCHAR(128),
	@CHECK	BIT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		IF @CHECK = 0
			EXEC sp_droprolemember @ROLE, @USER
		ELSE IF @CHECK = 1
			EXEC sp_addrolemember @ROLE, @USER
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