USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_DELETE_REPORT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@NAME	NVARCHAR(512),
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SET @END = DATEADD(DAY, 1, @END)
		
		SELECT ID, NAME, NUMBER, EDATE, UPD_USER
		FROM Client.Company a
		WHERE STATUS = 3
			AND (EDATE >= @BEGIN OR @BEGIN IS NULL)
			AND (EDATE < @END OR @END IS NULL)
			AND (NAME LIKE @NAME OR CONVERT(NVARCHAR(128), NUMBER) LIKE @NAME OR @NAME IS NULL)
			AND EXISTS
				(
					SELECT *
					FROM Client.Company b
					WHERE b.ID_MASTER = a.ID
				)
		ORDER BY NAME
		
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