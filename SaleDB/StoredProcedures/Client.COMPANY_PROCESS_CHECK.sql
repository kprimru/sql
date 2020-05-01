USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_PROCESS_CHECK]
	@ID		NVARCHAR(MAX),
	@TYPE	NVARCHAR(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @TYPE = N'SALE'
			SELECT
				(
					SELECT COUNT(*)
					FROM Common.TableGUIDFromXML(@ID) a
					WHERE NOT EXISTS
						(
							SELECT *
							FROM Client.CompanyProcessSaleView b WITH(NOEXPAND)
							WHERE b.ID = a.ID
						)
				) AS FREE_COUNT,
				(
					SELECT COUNT(*)
					FROM
						Common.TableGUIDFromXML(@ID) a
						INNER JOIN Client.CompanyProcessSaleView b WITH(NOEXPAND) ON b.ID = a.ID
				) AS PROCESS_COUNT
		ELSE IF @TYPE = N'PHONE'
			SELECT
				(
					SELECT COUNT(*)
					FROM Common.TableGUIDFromXML(@ID) a
					WHERE NOT EXISTS
						(
							SELECT *
							FROM Client.CompanyProcessPhoneView b WITH(NOEXPAND)
							WHERE b.ID = a.ID
						)
				) AS FREE_COUNT,
				(
					SELECT COUNT(*)
					FROM
						Common.TableGUIDFromXML(@ID) a
						INNER JOIN Client.CompanyProcessPhoneView b WITH(NOEXPAND) ON b.ID = a.ID
				) AS PROCESS_COUNT
		ELSE IF @TYPE = N'MANAGER'
			SELECT
				(
					SELECT COUNT(*)
					FROM Common.TableGUIDFromXML(@ID) a
					WHERE NOT EXISTS
						(
							SELECT *
							FROM Client.CompanyProcessManagerView b WITH(NOEXPAND)
							WHERE b.ID = a.ID
						)
				) AS FREE_COUNT,
				(
					SELECT COUNT(*)
					FROM
						Common.TableGUIDFromXML(@ID) a
						INNER JOIN Client.CompanyProcessManagerView b WITH(NOEXPAND) ON b.ID = a.ID
				) AS PROCESS_COUNT
		ELSE IF @TYPE = N'RIVAL'
			SELECT
				(
					SELECT COUNT(*)
					FROM Common.TableGUIDFromXML(@ID) a
					WHERE NOT EXISTS
						(
							SELECT *
							FROM Client.CompanyProcessRivalView b WITH(NOEXPAND)
							WHERE b.ID = a.ID
						)
				) AS FREE_COUNT,
				(
					SELECT COUNT(*)
					FROM
						Common.TableGUIDFromXML(@ID) a
						INNER JOIN Client.CompanyProcessRivalView b WITH(NOEXPAND) ON b.ID = a.ID
				) AS PROCESS_COUNT
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
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_CHECK] TO rl_company_process_manager;
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_CHECK] TO rl_company_process_phone;
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_CHECK] TO rl_company_process_return_manager;
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_CHECK] TO rl_company_process_return_phone;
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_CHECK] TO rl_company_process_return_sale;
GRANT EXECUTE ON [Client].[COMPANY_PROCESS_CHECK] TO rl_company_process_sale;
GO