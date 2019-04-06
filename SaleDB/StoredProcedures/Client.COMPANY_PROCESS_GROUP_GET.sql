USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_PROCESS_GROUP_GET]
	@LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		SELECT 
			(
				SELECT COUNT(*)
				FROM 
					Client.CompanyProcess a
					INNER JOIN Common.TableGUIDFromXML(@LIST) b ON a.ID_COMPANY = b.ID
				WHERE PROCESS_TYPE = N'PHONE'
					AND EDATE IS NULL
			) AS PHONE_COUNT,
			(
				SELECT COUNT(*)
				FROM 
					Client.CompanyProcess a
					INNER JOIN Common.TableGUIDFromXML(@LIST) b ON a.ID_COMPANY = b.ID
				WHERE PROCESS_TYPE = N'SALE'
					AND EDATE IS NULL
			) AS SALE_COUNT
		
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