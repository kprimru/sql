USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_SELECT]
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

		SELECT
			a.ID, dbo.DateOf(a.DATE) AS DATE, c.SHORT, b.NAME AS SER_NAME,
			d.NAME AS DOC_NAME, CURRENT_CONTRACT, START, FINISH, PayTypeName AS ContractPayName,
			'Служебная записка' AS TP_STR, 1 AS TP, '' AS NOTE, SYSTEMS,
			a.MONTH_PRICE, a.PERIOD_PRICE
		FROM
			Memo.ClientMemo a
			INNER JOIN Memo.Service b ON a.ID_SERVICE = b.ID
			INNER JOIN dbo.Vendor c ON a.ID_VENDOR = c.ID
			INNER JOIN Memo.Document d ON a.ID_DOC_TYPE = d.ID
			LEFT OUTER JOIN dbo.PayTypeTable e ON a.ID_PAY_TYPE = e.PayTypeID
		WHERE a.ID_CLIENT = @CLIENT

		UNION ALL

		SELECT
			a.ID, dbo.DateOf(a.DATE) AS DATE, NOTE, NULL,
			NULL, NULL, NULL, NULL, NULL,
			'Расчет' AS TP_STR, 2 AS TP, NOTE, SYSTEMS, NULL, NULL
		FROM Memo.ClientCalculation a
		WHERE a.ID_CLIENT = @CLIENT

		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_SELECT] TO rl_client_memo_r;
GO
