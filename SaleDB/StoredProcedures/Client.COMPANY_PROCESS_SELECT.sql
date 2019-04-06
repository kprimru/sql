USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_PROCESS_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@RC		INT				=	NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY		
		SELECT 
			a.ID, b.SHORT, PROCESS_TYPE, 
			CASE PROCESS_TYPE 
				WHEN N'PHONE' THEN N'��'
				WHEN N'SALE' THEN N'��'
				WHEN N'MANAGER' THEN N'��������'
				WHEN N'RIVAL' THEN '������������ ��������'
				ELSE N'???' 
			END AS PROCESS_TYPE_CAPT,
			BDATE, EDATE,
			CONVERT(NVARCHAR(32), ASSIGN_DATE, 104) + ' ' + 
				CONVERT(NVARCHAR(32), ASSIGN_DATE, 108) + ' ' + ASSIGN_USER AS ASSIGN_DATA
		FROM 
			Client.CompanyProcess a
			INNER JOIN Personal.OfficePersonal b ON a.ID_PERSONAL = b.ID
		WHERE ID_COMPANY = @ID
		ORDER BY ASSIGN_DATE DESC

		SELECT @RC = @@ROWCOUNT
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