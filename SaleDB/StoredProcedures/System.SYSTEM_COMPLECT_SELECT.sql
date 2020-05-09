USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[SYSTEM_COMPLECT_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			ID, SHORT, ORD, IBS_SIZE,
			Common.FileByteSizeToStr(IBS_SIZE) AS IBS_SIZE_STR,
			(
				SELECT TOP 1 PRICE
				FROM System.Price
			) AS PRICE,
			(
				SELECT TOP 1 PRICE
				FROM System.Price
			) AS PRICE_MONTH,
			(
				SELECT TOP 1 ID
				FROM System.Net
			) AS SN_ID,
			(
				SELECT TOP 1 SHORT
				FROM System.Net
			) AS SN_SHORT,
			(
				SELECT TOP 1 COEF
				FROM System.Net
			) AS SN_COEF
		FROM
			(
				SELECT
					a.ID, a.SHORT, a.NAME, a.ORD,
					(
						SELECT SUM(IBS_SIZE)
						FROM
							[PC275-SQL\ALPHA].ClientDB.dbo.InfoBankSizeView y WITH(NOEXPAND)
							INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemBanksView z WITH(NOEXPAND) ON z.InfoBankID = IBF_ID_IB
						WHERE z.SystemBaseName = a.REG
							AND IBS_DATE =
								(
									SELECT MAX(IBS_DATE)
									FROM [PC275-SQL\ALPHA].ClientDB.dbo.InfoBankSizeView t WITH(NOEXPAND)
									WHERE t.IBF_ID_IB = y.IBF_ID_IB
								)
					) AS IBS_SIZE
				FROM
					System.Systems a
				WHERE 1 = 0
			) AS o_O
		ORDER BY  NAME
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
GO
GRANT EXECUTE ON [System].[SYSTEM_COMPLECT_SELECT] TO rl_complect_calc;
GO