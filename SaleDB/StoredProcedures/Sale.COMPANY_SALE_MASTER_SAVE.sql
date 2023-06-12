USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Sale].[COMPANY_SALE_MASTER_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Sale].[COMPANY_SALE_MASTER_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Sale].[COMPANY_SALE_MASTER_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@COMPANY	UNIQUEIDENTIFIER,
	@OFFICE		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@INN		NVARCHAR(32),
	@STREET		UNIQUEIDENTIFIER,
	@HOME		NVARCHAR(64),
	@ROOM		NVARCHAR(64),
	@CONTRACT	NVARCHAR(64),
	@ASSIGN		UNIQUEIDENTIFIER,
	@RIVAL		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
		DECLARE @NEW UNIQUEIDENTIFIER

		IF @ID IS NULL
		BEGIN
			INSERT INTO Sale.SaleCompany(ID_COMPANY, ID_OFFICE, DATE, ID_ASSIGNER, ID_RIVAL)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@COMPANY, @OFFICE, @DATE, @ASSIGN, @RIVAL)

			SELECT @ID = ID
			FROM @TBL

			INSERT INTO Sale.SaleCompanyData(ID_SALE, INN, STREET, HOME, ROOM)
				VALUES(@ID, @INN, @STREET, @HOME, @ROOM)
		END
		ELSE
		BEGIN
			INSERT INTO Sale.SaleCompany(ID_MASTER, ID_COMPANY, ID_OFFICE, DATE, CONFIRMED, ID_ASSIGNER, ID_RIVAL, STATUS, BDATE, EDATE, UPD_USER)
				OUTPUT inserted.ID INTO @TBL
				SELECT ID, ID_COMPANY, ID_OFFICE, DATE, CONFIRMED, ID_ASSIGNER, ID_RIVAL, 2, BDATE, EDATE, UPD_USER
				FROM Sale.SaleCompany
				WHERE ID = @ID

			SELECT @NEW = ID FROM @TBL

			INSERT INTO Sale.SaleCompanyData(ID_SALE, INN, STREET, HOME, ROOM, CONTRACT)
				SELECT @NEW, INN, STREET, HOME, ROOM, CONTRACT
				FROM Sale.SaleCompanyData
				WHERE ID_SALE = @ID

			UPDATE Sale.SaleDistr
			SET ID_SALE = @NEW
			WHERE ID_SALE = @ID

			UPDATE Sale.SalePersonal
			SET ID_SALE = @NEW
			WHERE ID_SALE = @ID

			UPDATE Sale.SaleCompany
			SET ID_OFFICE	=	@OFFICE,
				DATE		=	@DATE,
				ID_ASSIGNER	=	@ASSIGN,
				ID_RIVAL	=	@RIVAL,
				BDATE		=	GETDATE(), 
				UPD_USER	=	ORIGINAL_LOGIN()
			WHERE ID = @ID

			UPDATE Sale.SaleCompanyData
			SET INN			=	@INN,
				STREET		=	@STREET,
				HOME		=	@HOME,
				ROOM		=	@ROOM,
				CONTRACT	=	@CONTRACT
			WHERE ID_SALE = @ID
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Sale].[COMPANY_SALE_MASTER_SAVE] TO rl_sale_w;
GO
