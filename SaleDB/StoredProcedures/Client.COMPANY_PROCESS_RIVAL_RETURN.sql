USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_RIVAL_RETURN]
	@COMPANY	NVARCHAR(MAX)
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

		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 14, ID_AVAILABILITY, ID_CHARACTER, c.ID_PERSONAL, N'��������� ������������� ��������� - �������'
			FROM
				Client.Company a
				INNER JOIN Common.TableGUIDFromXML(@COMPANY) b ON a.ID = b.ID
				INNER JOIN Client.CompanyProcessRivalView c WITH(NOEXPAND) ON c.ID = a.ID

		UPDATE Client.CompanyProcess
		SET EDATE = @DATE,
			RETURN_DATE = GETDATE(),
			RETURN_USER = ORIGINAL_LOGIN()
		WHERE EDATE IS NULL
			AND PROCESS_TYPE = N'RIVAL'
			AND ID_COMPANY IN
				(
					SELECT ID
					FROM Common.TableGUIDFromXML(@COMPANY) a
				)

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
					FROM Common.TableGUIDFromXML(@COMPANY) a
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_RIVAL_RETURN] TO rl_company_process_return_rival;
GO