USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_SALE]
	@COMPANY	NVARCHAR(MAX),
	@SALE		UNIQUEIDENTIFIER
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
					Client.CompanyProcessSaleView a WITH(NOEXPAND)
					INNER JOIN
						(
							SELECT c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID
							FROM @XML.nodes('/root/item') AS a(c)
						) AS b ON a.ID = b.ID
				FOR XML PATH('root')
			)

		EXEC Client.COMPANY_PROCESS_SALE_RETURN @RETURN

		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 2, ID_AVAILABILITY, ID_CHARACTER, @SALE, N'Изменение торгового представителя - Выдача'
			FROM
				Client.Company a
				INNER JOIN Common.TableGUIDFromXML(@COMPANY) b ON a.ID = b.ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessSaleView c WITH(NOEXPAND)
					WHERE c.ID = a.ID
				)

		INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
			SELECT ID, @SALE, N'SALE', @DATE
			FROM Common.TableGUIDFromXML(@COMPANY) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessSaleView c WITH(NOEXPAND)
					WHERE c.ID = a.ID
				)

		DECLARE @MANAGER UNIQUEIDENTIFIER

		SELECT @MANAGER = MANAGER
		FROM Personal.OfficePersonal
		WHERE ID = @SALE

		IF @MANAGER IS NOT NULL
			EXEC Client.COMPANY_PROCESS_MANAGER @COMPANY, @MANAGER

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

		UPDATE Meeting.AssignedMeeting
		SET ID_PERSONAL = @SALE
		WHERE ID_PERSONAL IS NULL
			AND ID_MASTER IS NULL
			AND ID_PARENT IS NULL
			AND ID_COMPANY IN
				(
					SELECT ID
					FROM Common.TableGUIDFromXML(@COMPANY)
				)
			AND
				(
					ID_STATUS IS NULL
					OR
					EXISTS
						(
							SELECT *
							FROM Meeting.MeetingStatus d
							WHERE d.ID = ID_STATUS
								AND d.STATUS IN (1, 2)
						)
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_SALE] TO rl_company_process_sale;
GO