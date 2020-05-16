USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_UNSET]
	@ID		UNIQUEIDENTIFIER,
	@PHONE	BIT,
	@SALE	BIT,
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
		IF @PHONE = 1
		BEGIN
			UPDATE Client.CompanyProcess
			SET EDATE = @DATE,
				RETURN_DATE = GETDATE(),
				RETURN_USER = ORIGINAL_LOGIN()
			WHERE ID_COMPANY = @ID
				AND EDATE IS NULL
				AND PROCESS_TYPE = N'PHONE'

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT @ID, @DATE, 5, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, N'Изменение телефонного агента - Возврат'
				FROM
					Client.Company a
					INNER JOIN Client.CompanyProcess b ON a.ID = b.ID_COMPANY
				WHERE a.ID = @ID
					AND b.EDATE IS NULL
					AND PROCESS_TYPE = N'PHONE'
		END

		IF @SALE = 1
		BEGIN
			UPDATE Client.CompanyProcess
			SET EDATE = @DATE,
				RETURN_DATE = GETDATE(),
				RETURN_USER = ORIGINAL_LOGIN()
			WHERE ID_COMPANY = @ID
				AND EDATE IS NULL
				AND PROCESS_TYPE = N'SALE'

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT @ID, @DATE, 6, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, N'Изменение торгового представителя - Возврат'
				FROM
					Client.Company a
					INNER JOIN Client.CompanyProcess b ON a.ID = b.ID_COMPANY
				WHERE a.ID = @ID
					AND b.EDATE IS NULL
					AND PROCESS_TYPE = N'SALE'
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_UNSET] TO rl_company_process_w;
GO