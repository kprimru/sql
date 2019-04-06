USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_WARNING_FILTER]
	@TYPE		TINYINT,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TEXT		VARCHAR(500),
	@PERS		UNIQUEIDENTIFIER,
	@RC			INT = NULL OUTPUT	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SET @END = DATEADD(DAY, 1, @END)

		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words

		CREATE TABLE #words
				(
					WRD		VARCHAR(250) PRIMARY KEY
				)		

		IF @TEXT IS NOT NULL
			INSERT INTO #words(WRD)
				SELECT '%' + Word + '%'
				FROM Common.SplitString(@TEXT)		

		SELECT 
			b.ID AS ID,
			b.NAME AS CO_NAME, DATE, NOTE, END_DATE, b.NUMBER,
			ISNULL((SELECT TOP 1 SHORT FROM Personal.OfficePersonal WHERE LOGIN = a.UPD_USER), a.UPD_USER) AS CONTROL_USER
		FROM
			Client.CompanyWarning a
			INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
			--INNER JOIN Client.CompanyReadList() c ON c.ID = b.ID				
		WHERE --a.ID_MASTER IS NULL
			a.STATUS = 1
			AND (DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (DATE < @END OR @END IS NULL)
			AND (@PERS IS NULL OR (SELECT TOP 1 ID FROM Personal.OfficePersonal WHERE [LOGIN] = a.UPD_USER) = @PERS OR (SELECT TOP 1 ID FROM Personal.OfficePersonal WHERE [LOGIN] = a.CREATE_USER) = @PERS)
			AND (@TYPE IS NULL OR @TYPE = 0 OR @TYPE = 1 AND END_DATE IS NULL OR @TYPE = 2 AND END_DATE IS NOT NULL)
			AND 
				(
					@TEXT IS NULL
					OR
					NOT EXISTS
						(
							SELECT *
							FROM #words
							WHERE NOT(NOTE LIKE WRD)
						)
				)
		ORDER BY DATE DESC, CO_NAME

		SELECT @RC = @@ROWCOUNT		
		
		IF OBJECT_ID('tempdb..#words') IS NOT NULL
			DROP TABLE #words
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
