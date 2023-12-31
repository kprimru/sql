USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_MEMO_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client(ClientID INT PRIMARY KEY)

		INSERT INTO #client(ClientID)
			SELECT DISTINCT b.ID_CLIENT
			FROM
				(
					SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM
					FROM dbo.ClientDistrView
					WHERE CD_ID_CLIENT = @CLIENT
				) AS a
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView b WITH(NOEXPAND) ON a.SYS_REG_NAME = b.SystemBaseName AND a.DIS_NUM = b.DISTR AND a.DIS_COMP_NUM = b.COMP

		SELECT a.ID, a.DATE AS [MEMO_DATE], '' AS [MEMO_NAME], '��������� �������' AS TP, 0 AS CURVED, MONTH_PRICE AS [MEMO_PRICE]
		FROM
			[PC275-SQL\ALPHA].ClientDB.Memo.ClientMemo a
			INNER JOIN #client b ON a.ID_CLIENT = b.ClientID
		/*
		UNION ALL

		SELECT a.ID, a.DATE, a.NOTE, '������' AS TP, 0 AS CURVED, NULL AS PERIOD_PRICE
		FROM
			[PC275-SQL\ALPHA].ClientDB.Memo.ClientCalculation a
			INNER JOIN #client b ON a.ID_CLIENT = b.ClientID
		*/
		UNION ALL

		SELECT
			DISTINCT a.ID, a.DATE, a.NAME, '������ ��� ��������' AS TP, 1 AS CURVED,
			(
				SELECT SUM(z.TOTAL_PRICE)
				FROM [PC275-SQL\ALPHA].ClientDB.Memo.KGSMemoDistr z
				WHERE a.ID = z.ID_MEMO
					AND z.CURVED = 1
			)
		FROM
			[PC275-SQL\ALPHA].ClientDB.Memo.KGSMemo a
			INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.KGSMemoDistr b ON a.ID = b.ID_MEMO
			INNER JOIN #client c ON b.ID_CLIENT = c.ClientID
		WHERE a.STATUS = 1 AND b.CURVED = 1
		/*
		UNION ALL

		SELECT
			DISTINCT a.ID, a.DATE, a.NAME, '������ ��� ��������������' AS TP, 0 AS CURVED,
			(
				SELECT SUM(z.TOTAL_PRICE)
				FROM [PC275-SQL\ALPHA].ClientDB.Memo.KGSMemoDistr z
				WHERE a.ID = z.ID_MEMO
					AND z.CURVED = 0
			)
		FROM
			[PC275-SQL\ALPHA].ClientDB.Memo.KGSMemo a
			INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.KGSMemoDistr b ON a.ID = b.ID_MEMO
			INNER JOIN #client c ON b.ID_CLIENT = c.ClientID
		WHERE a.STATUS = 1 AND b.CURVED = 0
		*/
		ORDER BY MEMO_DATE DESC, MEMO_NAME

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CLIENT_MEMO_SELECT] TO rl_distr_financing_w;
GO
