USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Client].[OFFICE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@COMPANY	UNIQUEIDENTIFIER,
	@SHORT		NVARCHAR(128),
	@NAME		NVARCHAR(448),
	@MAIN		BIT,
	@AREA		UNIQUEIDENTIFIER,
	@STREET		UNIQUEIDENTIFIER,
	@INDEX		NVARCHAR(64),
	@HOME		NVARCHAR(64),
	@ROOM		NVARCHAR(64),
	@NOTE		NVARCHAR(MAX)	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY	
		BEGIN TRAN Office

		INSERT INTO Client.Office(ID_MASTER, ID_COMPANY, SHORT, NAME, MAIN, BDATE, EDATE, STATUS, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_COMPANY, SHORT, NAME, MAIN, BDATE, EDATE, 2, UPD_USER
			FROM Client.Office
			WHERE ID = @ID
		
		DECLARE @NEW_ID UNIQUEIDENTIFIER

		SELECT @NEW_ID = ID
		FROM @TBL

		INSERT INTO Client.OfficeAddress(ID_OFFICE, ID_AREA, ID_STREET, [INDEX], HOME, ROOM, NOTE)
			SELECT @NEW_ID, ID_AREA, ID_STREET, [INDEX], HOME, ROOM, NOTE
			FROM Client.OfficeAddress
			WHERE ID_OFFICE = @ID
	
		UPDATE Client.Office
		SET SHORT	=	@SHORT,
			NAME	=	@NAME,
			MAIN	=	@MAIN,
			BDATE	=	GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID		

		UPDATE Client.OfficeAddress
		SET ID_AREA		=	@AREA,
			ID_STREET	=	@STREET,
			[INDEX]		=	@INDEX,
			HOME		=	@HOME,
			ROOM		=	@ROOM,
			NOTE		=	@NOTE
		WHERE ID_OFFICE	=	@ID

		IF @@ROWCOUNT = 0
			INSERT INTO Client.OfficeAddress(ID_OFFICE, ID_AREA, ID_STREET, [INDEX], HOME, ROOM, NOTE)
				VALUES(@ID, @AREA, @STREET, @INDEX, @HOME, @ROOM, @NOTE)

		EXEC Client.COMPANY_REINDEX @COMPANY, NULL

		COMMIT TRAN Office
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN Office

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