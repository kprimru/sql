USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[KGS_MEMO_DISTR_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[KGS_MEMO_DISTR_GET]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Memo].[KGS_MEMO_DISTR_GET]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Date			SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @Date = P.[START]
		FROM [Memo].[KGSMemo]			AS K
		INNER JOIN [Common].[Period]	AS P ON P.[ID] = K.[ID_MONTH]
		WHERE K.ID = @ID

		SELECT
			a.ID_CLIENT, a.NUM,
			SystemID, SystemShortName, SystemOrder,
			dbo.DistrString(NULL, DISTR, COMP) AS DISTR_STR,
			DISTR, COMP,
			DistrTypeID, DistrTypeName, DistrTypeOrder,
			SystemTypeID, SystemTypeName,
			DISCOUNT, INFLATION,
			b.PRICE, b.MON_CNT, b.PRICE, b.TAX_PRICE, b.TOTAL_PRICE, b.TOTAL_PRICE * b.MON_CNT AS TOTAL_PERIOD,
			a.NAME, a.ADDRESS, b.MON_CNT
		FROM
			Memo.KGSMemoClient a
			INNER JOIN Memo.KGSMemoDistr b ON a.ID_MEMO = b.ID_MEMO AND a.ID_CLIENT = b.ID_CLIENT
			INNER JOIN dbo.SystemTable c ON c.SystemID = b.ID_SYSTEM
			INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = b.ID_NET
			INNER JOIN dbo.SystemTypeTable e ON e.SystemTypeID = b.ID_TYPE
			INNER JOIN [Price].[Systems:Price@Get](@Date) AS G ON G.[System_Id] = b.[ID_SYSTEM]
		WHERE a.ID_MEMO = @ID AND CURVED = 1
		ORDER BY a.NUM, c.SystemOrder, d.DistrTypeOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[KGS_MEMO_DISTR_GET] TO rl_kgs_complect_calc;
GO
