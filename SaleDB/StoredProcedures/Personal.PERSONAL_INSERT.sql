USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Personal].[PERSONAL_INSERT]
	@MANAGER	UNIQUEIDENTIFIER,
	@SURNAME	NVARCHAR(256),
	@NAME		NVARCHAR(256),
	@PATRON		NVARCHAR(256),
	@SHORT		NVARCHAR(128),
	@PHONE		NVARCHAR(128),
	@PHONE_OF	NVARCHAR(128),
	@ID_TYPE	NVARCHAR(MAX),
	@AUTH		SMALLINT,
	@LOGIN		NVARCHAR(128),
	@PASS		NVARCHAR(128),
	@ROLE		UNIQUEIDENTIFIER,	
	@START_DATE	SMALLDATETIME,	
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE
		(
			ID	UNIQUEIDENTIFIER
		)

	BEGIN TRY
		IF @START_DATE IS NULL
			SET @START_DATE = Common.DateOf(GETDATE())

		INSERT INTO Personal.OfficePersonal(MANAGER, SURNAME, NAME, PATRON, SHORT, LOGIN, PASS, START_DATE, PHONE, PHONE_OFFICE)
			OUTPUT inserted.ID INTO @TBL(ID)
			VALUES(@MANAGER, @SURNAME, @NAME, @PATRON, @SHORT, @LOGIN, @PASS, @START_DATE, @PHONE, @PHONE_OF)

		SELECT @ID = ID FROM @TBL

		INSERT INTO Personal.OfficePersonalType(ID_PERSONAL, ID_TYPE)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@ID_TYPE)

		IF @LOGIN IS NOT NULL AND @PASS IS NOT NULL
			EXEC Security.USER_CREATE @AUTH, @LOGIN, @SHORT, @PASS, @ROLE
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