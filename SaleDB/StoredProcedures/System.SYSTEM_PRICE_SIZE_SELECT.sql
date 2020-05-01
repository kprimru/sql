USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[SYSTEM_PRICE_SIZE_SELECT]
	@FILTER	NVARCHAR(256),
	@RC		INT	= NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @CUR_MONTH	UNIQUEIDENTIFIER

		SELECT @CUR_MONTH = ID
		FROM Common.Month
		WHERE DATE =
			(
				SELECT MAX(DATE)
				FROM Common.Month
				WHERE DATE < GETDATE()
			)

		SELECT
			ID, SHORT, NAME, ORD, IBS_SIZE,
			Common.FileByteSizeToStr(IBS_SIZE) AS IBS_SIZE_STR,
			(
				SELECT TOP 1 PRICE
				FROM System.Price
				WHERE ID_MONTH = @CUR_MONTH
					AND ID_SYSTEM = o_O.ID
				--ORDER BY LAST DESC
			) AS PRICE
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
				WHERE	@FILTER IS NULL
						OR (a.NAME LIKE @FILTER)
						OR (a.SHORT LIKE @FILTER)
			) AS o_O
		ORDER BY  ORD

		SET @RC = @@ROWCOUNT
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
GRANT EXECUTE ON [System].[SYSTEM_PRICE_SIZE_SELECT] TO rl_complect_calc;
GO