USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_PROCESS_SALE_RETURN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_PROCESS_SALE_RETURN]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_SALE_RETURN]
	@COMPANY	NVARCHAR(MAX),
	@COMPANYW   NVARCHAR(MAX)       = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @DATE SMALLDATETIME
    SET @DATE = Common.DateOf(GETDATE())
    DECLARE @Companies Table (ID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY CLUSTERED);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY

		IF @COMPANYW IS NOT NULL
		    SET @COMPANY = @COMPANYW
		ELSE
		    SET @COMPANY = Client.CompanyFilterWrite(@COMPANY);

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'SET @COMPANY = Client.CompanyFilterWrite(@COMPANY)';

		INSERT INTO @Companies
        SELECT ID
        FROM Common.TableGUIDFromXML(@COMPANY);

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO @Companies';

		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 6, ID_AVAILABILITY, ID_CHARACTER, c.ID_PERSONAL, N'Изменение торгового представителя - Возврат'
			FROM
				Client.Company a
				INNER JOIN @Companies b ON a.ID = b.ID
				INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON c.ID = a.ID

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO Client.CompanyProcessJournal';

		UPDATE Client.CompanyProcess
		SET EDATE = @DATE,
			RETURN_DATE = GETDATE(),
			RETURN_USER = ORIGINAL_LOGIN()
		WHERE EDATE IS NULL
			AND PROCESS_TYPE = N'SALE'
			AND ID_COMPANY IN
				(
					SELECT ID
					FROM @Companies a
				)

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE Client.CompanyProcess';

		DECLARE @WS UNIQUEIDENTIFIER

		SELECT @WS = ID
		FROM Client.WorkState
		WHERE ARCHIVE_AUTO = 1

		IF @WS IS NOT NULL
			UPDATE Client.Company
			SET ID_WORK_STATE = @WS
			WHERE ID IN
				(
					SELECT ID
					FROM @Companies a
				)

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'UPDATE Client.Company SET ID_WORK_STATE';

		EXEC Client.COMPANY_REINDEX NULL, @COMPANY

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'EXEC Client.COMPANY_REINDEX';

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_SALE_RETURN] TO rl_company_process_return_sale;
GO
