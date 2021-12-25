USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_MANAGER]
	@COMPANY	NVARCHAR(MAX),
	@MANAGER	UNIQUEIDENTIFIER,
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

		DECLARE @XML XML

		SELECT @XML = CAST(@COMPANY AS XML)

		DECLARE @RETURN	NVARCHAR(MAX)

		SET @RETURN =
			(
				SELECT a.ID AS 'item/@id'
				FROM
					Client.CompanyProcessManagerView a WITH(NOEXPAND)
					INNER JOIN @Companies AS b ON a.ID = b.ID
				WHERE ID_PERSONAL <> @MANAGER
				FOR XML PATH('root')
			)

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'SET @RETURN = ';

		IF @RETURN IS NOT NULL
			EXEC Client.COMPANY_PROCESS_MANAGER_RETURN @RETURN, @RETURN

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'EXEC Client.COMPANY_PROCESS_MANAGER_RETURN';

		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 9, ID_AVAILABILITY, ID_CHARACTER, @MANAGER, N'Изменение менеждера - Выдача'
			FROM
				Client.Company a
				INNER JOIN @Companies b ON a.ID = b.ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessManagerView c WITH(NOEXPAND)
					WHERE c.ID = a.ID
				)

		EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO Client.CompanyProcessJournal';

		INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
			SELECT ID, @MANAGER, N'MANAGER', @DATE
			FROM @Companies a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessManagerView c WITH(NOEXPAND)
					WHERE c.ID = a.ID
				)

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'INSERT INTO Client.CompanyProcess';

		DECLARE @WS UNIQUEIDENTIFIER

		SELECT @WS = ID
		FROM Client.WorkState
		WHERE SALE_AUTO = 1

		IF @WS IS NOT NULL
			UPDATE Client.Company
			SET ID_WORK_STATE = @WS
			WHERE ID IN
				(
					SELECT ID
					FROM @Companies
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_MANAGER] TO rl_company_process_manager;
GO
