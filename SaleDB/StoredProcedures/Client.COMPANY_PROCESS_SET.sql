USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PROCESS_SET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PROCESS_SET]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_SET]
	@ID		UNIQUEIDENTIFIER,
	@PHONE	UNIQUEIDENTIFIER,
	@SALE	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME
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
		IF @PHONE IS NOT NULL
		BEGIN
			INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
				SELECT @ID,	@PHONE, N'PHONE', @DATE

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT @ID, @DATE, 1, ID_AVAILABILITY, ID_CHARACTER, @PHONE, N'Изменение телефонного агента - Выдача'
				FROM Client.Company
				WHERE ID = @ID
		END

		IF @SALE IS NOT NULL
		BEGIN
			INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
				SELECT @ID,	@SALE, N'SALE', @DATE

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT @ID, @DATE, 2, ID_AVAILABILITY, ID_CHARACTER, @SALE, N'Изменение торгового представителя - Выдача'
				FROM Client.Company
				WHERE ID = @ID
		END

		EXEC Client.COMPANY_REINDEX @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_SET] TO rl_company_process_w;
GO
