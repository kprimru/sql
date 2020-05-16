USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_MANAGER]
	@COMPANY	NVARCHAR(MAX),
	@MANAGER	UNIQUEIDENTIFIER
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
		DECLARE @DATE SMALLDATETIME
		SET @DATE = Common.DateOf(GETDATE())

		SET @COMPANY = Client.CompanyFilterWrite(@COMPANY)

		DECLARE @XML XML

		SELECT @XML = CAST(@COMPANY AS XML)

		DECLARE @RETURN	NVARCHAR(MAX)

		SET @RETURN =
			(
				SELECT a.ID AS 'item/@id'
				FROM
					Client.CompanyProcessManagerView a WITH(NOEXPAND)
					INNER JOIN
						(
							SELECT c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID
							FROM @XML.nodes('/root/item') AS a(c)
						) AS b ON a.ID = b.ID
				WHERE ID_PERSONAL <> @MANAGER
				FOR XML PATH('root')
			)

		IF @RETURN IS NOT NULL
			EXEC Client.COMPANY_PROCESS_MANAGER_RETURN @RETURN

		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 9, ID_AVAILABILITY, ID_CHARACTER, @MANAGER, N'Изменение менеждера - Выдача'
			FROM
				Client.Company a
				INNER JOIN Common.TableGUIDFromXML(@COMPANY) b ON a.ID = b.ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessManagerView c WITH(NOEXPAND)
					WHERE c.ID = a.ID
				)

		INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
			SELECT ID, @MANAGER, N'MANAGER', @DATE
			FROM Common.TableGUIDFromXML(@COMPANY) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessManagerView c WITH(NOEXPAND)
					WHERE c.ID = a.ID
				)

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
					FROM Common.TableGUIDFromXML(@COMPANY)
				)

		EXEC Client.COMPANY_REINDEX NULL, @COMPANY

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