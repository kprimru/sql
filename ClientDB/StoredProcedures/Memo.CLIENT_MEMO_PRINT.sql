USE [ClientDB]
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
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			ClientFullName AS CLIENT, CURRENT_CONTRACT AS CONTRACT, DISTR, d.NAME AS DOC_TYPE, b.NAME AS SERVICE,
			c.SHORT AS VENDOR,
			ISNULL('� ' + CONVERT(VARCHAR(20), START, 104), '') + ISNULL(' �� ' + CONVERT(VARCHAR(20), FINISH, 104), '') AS DATE,
			Common.MoneyShort(MONTH_PRICE) + ' (� �.�. ���)' AS [MONTH],
			Common.MoneyShort(PERIOD_PRICE) + ' (� �.�. ���)' AS PERIOD,
			Common.MoneyShort(PERIOD_FULL_PRICE) + ' (� �.�. ���)' AS PERIOD_FULL,
			'� ' + CONVERT(VARCHAR(20), PERIOD_START, 104) + ' �� ' + CONVERT(VARCHAR(20), PERIOD_END, 104) AS PERIOD_STR,
			e.PayTypeName AS CONTRACT_PAY, g.ContractPayName AS CONTRACT_PAY_NAME,
			FRAMEWORK, DOCUMENTS, CASE LETTER_CANCEL WHEN 1 THEN '��' ELSE '���' END AS LETTER_CANCEL, SYSTEMS,
			ISNULL(
				(
					SELECT CONVERT(VARCHAR(20), ORD) + '. ' + CONDITION + CHAR(10)
					FROM Memo.ClientMemoConditions z
					WHERE z.ID_MEMO = a.ID
					ORDER BY ORD FOR XML PATH(''), TYPE
				), '') AS CONDITION,
			ISNULL(
				(
					SELECT S.NAME + CHAR(10)
					FROM Memo.ClientMemoSpecifications z
					INNER JOIN Contract.ContractSpecification AS CS ON Z.Specification_Id = CS.ID
					INNER JOIN Contract.Specification AS S ON S.[ID] = CS.[ID_SPECIFICATION]
					WHERE z.Memo_Id = a.ID
					FOR XML PATH(''), TYPE
				), '') AS SPECIFICATIONS,
			ISNULL(
				(
					SELECT '� ' + Cast(CS.NUM AS VarChar(100)) + CHAR(10)
					FROM Memo.ClientMemoAdditionals z
					INNER JOIN Contract.Additional AS CS ON Z.Additional_Id = CS.ID
					WHERE z.Memo_Id = a.ID
					FOR XML PATH(''), TYPE
				), '') AS ADDITIONALS
		FROM
			Memo.ClientMemo a
			INNER JOIN Memo.Service b ON a.ID_SERVICE = b.ID
			INNER JOIN dbo.Vendor c ON a.ID_VENDOR = c.ID
			INNER JOIN Memo.Document d ON a.ID_DOC_TYPE = d.ID
			LEFT OUTER JOIN dbo.PayTypeTable e ON a.ID_PAY_TYPE = e.PayTypeID
			INNER JOIN dbo.ClientTable f ON a.ID_CLIENT = f.ClientID
			LEFT OUTER JOIN dbo.ContractPayTable g ON g.ContractPayID = a.ID_CONTRACT_PAY_TYPE
		WHERE a.ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_PRINT] TO rl_client_memo_r;
GO
