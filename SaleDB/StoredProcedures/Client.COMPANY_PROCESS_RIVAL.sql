USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_PROCESS_RIVAL]
	@COMPANY	NVARCHAR(MAX),
	@SALE		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

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
					Client.CompanyProcessRivalView a WITH(NOEXPAND)
					INNER JOIN
						(
							SELECT c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID
							FROM @XML.nodes('/root/item') AS a(c)
						) AS b ON a.ID = b.ID
				FOR XML PATH('root')
			)
			
		EXEC Client.COMPANY_PROCESS_RIVAL_RETURN @RETURN
				
		INSERT INTO Client.CompanyProcessJournal(ID_COMPANY, DATE, TYPE, ID_AVAILABILITY, ID_CHARACTER, ID_PERSONAL, MESSAGE)
			SELECT a.ID, @DATE, 13, ID_AVAILABILITY, ID_CHARACTER, @SALE, N'��������� ������������� ��������� - ������'
			FROM 
				Client.Company a
				INNER JOIN Common.TableGUIDFromXML(@COMPANY) b ON a.ID = b.ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessRivalView c WITH(NOEXPAND) 
					WHERE c.ID = a.ID
				)
				
		INSERT INTO Client.CompanyProcess(ID_COMPANY, ID_PERSONAL, PROCESS_TYPE, BDATE)
			SELECT ID, @SALE, N'RIVAL', @DATE
			FROM Common.TableGUIDFromXML(@COMPANY) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Client.CompanyProcessRivalView c WITH(NOEXPAND) 
					WHERE c.ID = a.ID
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
