USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[System].[SYSTEM_COMPLECT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [System].[SYSTEM_COMPLECT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [System].[SYSTEM_COMPLECT_SELECT]
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

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [System].[SYSTEM_COMPLECT_SELECT] TO rl_complect_calc;
GO
