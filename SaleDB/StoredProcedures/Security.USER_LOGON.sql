USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Security].[USER_LOGON]
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT,
	@PERS	UNIQUEIDENTIFIER = NULL OUTPUT,
	@NAME	NVARCHAR(128) = NULL OUTPUT,
	@ORG	NVARCHAR(128) = NULL OUTPUT,
	@MONTH	UNIQUEIDENTIFIER = NULL OUTPUT,
	@MON_PRICE	UNIQUEIDENTIFIER = NULL OUTPUT,
	@MET_DELTA	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		EXEC [Security].[USER_ID] @ID OUTPUT
		EXEC Personal.PERSONAL_ID @PERS OUTPUT, @NAME OUTPUT
		EXEC Common.GLOBAL_SETTING_GET N'ORG_NAME', @ORG OUTPUT
		EXEC Common.GLOBAL_SETTING_GET N'MEETING_DELTA', @MET_DELTA OUTPUT
				
		SELECT @MONTH = ID
		FROM Common.Month
		WHERE GETDATE() BETWEEN DATE AND DATEADD(MONTH, 1, DATE)
		
		SELECT @MON_PRICE = ID
		FROM Common.Month
		WHERE DATE = 
			(
				SELECT MAX(DATE)
				FROM 
					Common.Month a
					INNER JOIN System.Price b ON a.ID = b.ID_MONTH
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