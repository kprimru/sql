USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Sale].[COMPANY_SALE_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRAN SaleDelete

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		DECLARE @NEW	UNIQUEIDENTIFIER

		INSERT INTO Sale.SaleCompany(ID_MASTER, ID_COMPANY, ID_OFFICE, DATE, CONFIRMED, STATUS, BDATE, EDATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, ID_COMPANY, ID_OFFICE, DATE, CONFIRMED, 2, BDATE, EDATE, UPD_USER
			FROM Sale.SaleCompany
			WHERE ID = @ID

		SELECT @NEW = ID FROM @TBL

		INSERT INTO Sale.SaleCompanyData(ID_SALE, INN, STREET, HOME, ROOM, CONTRACT)
			SELECT @NEW, INN, STREET, HOME, ROOM, CONTRACT
			FROM Sale.SaleCompanyData
			WHERE ID_SALE = @ID

		INSERT INTO Sale.SaleDistr(ID_SALE, ID_SYSTEM, ID_NET, CNT)
			SELECT @NEW, ID_SYSTEM, ID_NET, CNT
			FROM Sale.SaleDistr
			WHERE ID_SALE = @ID

		INSERT INTO Sale.SalePersonal(ID_SALE, ID_PERSONAL, VALUE)
			SELECT @NEW, ID_PERSONAL, VALUE
			FROM Sale.SalePersonal
			WHERE ID = @ID

		UPDATE Sale.SaleCompany
		SET STATUS = 3,
			EDATE = GETDATE(),
			UPD_USER = ORIGINAL_LOGIN()
		WHERE ID = @ID

		COMMIT TRAN SaleDelete
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN SaleDelete

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
GRANT EXECUTE ON [Sale].[COMPANY_SALE_DELETE] TO rl_sale_d;
GO