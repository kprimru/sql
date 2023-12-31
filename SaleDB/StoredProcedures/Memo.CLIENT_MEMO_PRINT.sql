USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_PRINT]
	@ID	UNIQUEIDENTIFIER
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

	SELECT
		f.NAME AS CLIENT, d.NAME AS DOC_TYPE, b.NAME AS SERVICE,
		c.SHORT AS VENDOR,
		ISNULL('� ' + CONVERT(VARCHAR(20), START, 104), '') + ISNULL(' �� ' + CONVERT(VARCHAR(20), FINISH, 104), '') AS DATE,
		Common.MoneyShort(MONTH_PRICE) + ' (� �.�. ��� 18%)' AS [MONTH],
		Common.MoneyShort(PERIOD_PRICE) + ' (� �.�. ��� 18%)' AS PERIOD,
		Common.MoneyShort(PERIOD_FULL_PRICE) + ' (� �.�. ��� 18%)' AS PERIOD_FULL,
		'� ' + CONVERT(VARCHAR(20), PERIOD_START, 104) + ' �� ' + CONVERT(VARCHAR(20), PERIOD_FINISH, 104) AS PERIOD_STR,
		e.PayTypeName AS CONTRACT_PAY, g.ContractPayName AS CONTRACT_PAY_NAME,
		FRAMEWORK, DOCUMENTS, CASE LETTER_CANCEL WHEN 1 THEN '��' ELSE '���' END AS LETTER_CANCEL, SYSTEMS,
		ISNULL(
			(
				SELECT CONVERT(VARCHAR(20), ORD) + '. ' + CONDITION + CHAR(10)
				FROM Memo.ClientMemoConditions z
				WHERE z.ID_MEMO = a.ID
				ORDER BY ORD FOR XML PATH(''), TYPE
			), '') AS CONDITION
	FROM
		Memo.ClientMemo a
		INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.Service b ON a.ID_SERVICE = b.ID
		INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.Vendor c ON a.ID_VENDOR = c.ID
		INNER JOIN [PC275-SQL\ALPHA].ClientDB.Memo.Document d ON a.ID_DOC_TYPE = d.ID
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.PayTypeTable e ON a.ID_PAY_TYPE = e.PayTypeID
		INNER JOIN Client.Company f ON a.ID_CLIENT = f.ID
		LEFT OUTER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.ContractPayTable g ON g.ContractPayID = a.ID_CONTRACT_PAY
	WHERE a.ID = @ID
END

GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_PRINT] TO rl_client_memo_r;
GO
