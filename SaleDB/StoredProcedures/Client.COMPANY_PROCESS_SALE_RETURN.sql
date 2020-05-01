USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_SALE_RETURN]
	@COMPANY	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @DATE SMALLDATETIME
		SET @DATE = Common.DateOf(GETDATE())

		SET @COMPANY = Client.CompanyFilterWrite(@COMPANY)

		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 6, ID_AVAILABILITY, ID_CHARACTER, c.ID_PERSONAL, N'��������� ��������� ������������� - �������'
			FROM
				Client.Company a
				INNER JOIN Common.TableGUIDFromXML(@COMPANY) b ON a.ID = b.ID
				INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON c.ID = a.ID

		UPDATE Client.CompanyProcess
		SET EDATE = @DATE,
			RETURN_DATE = GETDATE(),
			RETURN_USER = ORIGINAL_LOGIN()
		WHERE EDATE IS NULL
			AND PROCESS_TYPE = N'SALE'
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
	END TRY
	BEGIN CATCH
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_SALE_RETURN] TO rl_company_process_return_sale;
GO