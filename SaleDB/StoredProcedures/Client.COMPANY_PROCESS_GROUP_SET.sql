USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_GROUP_SET]
	@LIST	NVARCHAR(MAX),
	@PHONE	UNIQUEIDENTIFIER,
	@SALE	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RETURN	SMALLDATETIME
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
			UPDATE a
			SET EDATE = @RETURN,
				RETURN_DATE = GETDATE(),
				RETURN_USER = ORIGINAL_LOGIN()
			FROM
				Client.CompanyProcess a
				INNER JOIN Common.TableGUIDFromXML(@LIST) b ON a.ID_COMPANY = b.ID
			WHERE EDATE IS NULL
				AND PROCESS_TYPE = N'PHONE'

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT a.ID, @DATE, 5, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, N'Изменение телефонного агента - Возврат'
				FROM
					Client.Company a
					INNER JOIN Client.CompanyProcess b ON a.ID = b.ID_COMPANY
					INNER JOIN Common.TableGUIDFromXML(@LIST) c ON a.ID = c.ID
				WHERE b.EDATE IS NULL
					AND PROCESS_TYPE = N'PHONE'

			INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
				SELECT ID,	@PHONE, N'PHONE', @DATE
				FROM Common.TableGUIDFromXML(@LIST) b

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT a.ID, @DATE, 1, ID_AVAILABILITY, ID_CHARACTER, @PHONE, N'Изменение телефонного агента - Выдача'
				FROM
					Client.Company a
					INNER JOIN Common.TableGUIDFromXML(@LIST) c ON a.ID = c.ID
		END

		IF @SALE IS NOT NULL
		BEGIN
			UPDATE a
			SET EDATE = @RETURN,
				RETURN_DATE = GETDATE(),
				RETURN_USER = ORIGINAL_LOGIN()
			FROM
				Client.CompanyProcess a
				INNER JOIN Common.TableGUIDFromXML(@LIST) b ON a.ID_COMPANY = b.ID
			WHERE EDATE IS NULL
				AND PROCESS_TYPE = N'SALE'

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT a.ID, @DATE, 6, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, N'Изменение торгового представителя - Возврат'
				FROM
					Client.Company a
					INNER JOIN Client.CompanyProcess b ON a.ID = b.ID_COMPANY
					INNER JOIN Common.TableGUIDFromXML(@LIST) c ON a.ID = c.ID
				WHERE b.EDATE IS NULL
					AND PROCESS_TYPE = N'SALE'

			INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
				SELECT ID,	@PHONE, N'SALE', @DATE
				FROM Common.TableGUIDFromXML(@LIST) b

			INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
				SELECT a.ID, @DATE, 2, ID_AVAILABILITY, ID_CHARACTER, @PHONE, N'Изменение торгового представителя - Выдача'
				FROM
					Client.Company a
					INNER JOIN Common.TableGUIDFromXML(@LIST) c ON a.ID = c.ID
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_GROUP_SET] TO rl_company_group;
GO
