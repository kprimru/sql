USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[OFFICE_INSERT]
	@COMPANY	UNIQUEIDENTIFIER,
	@SHORT		NVARCHAR(128),
	@NAME		NVARCHAR(448),
	@MAIN		BIT,
	@AREA		UNIQUEIDENTIFIER,
	@STREET		UNIQUEIDENTIFIER,
	@INDEX		NVARCHAR(64),
	@HOME		NVARCHAR(64),
	@ROOM		NVARCHAR(64),
	@NOTE		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	BEGIN TRY
		BEGIN TRAN Office

		INSERT INTO Client.Office(ID_COMPANY, SHORT, NAME, MAIN)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@COMPANY, @SHORT, @NAME, @MAIN)

		SELECT @ID = ID FROM @TBL

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
GO
GRANT EXECUTE ON [Client].[OFFICE_INSERT] TO rl_office_w;
GO