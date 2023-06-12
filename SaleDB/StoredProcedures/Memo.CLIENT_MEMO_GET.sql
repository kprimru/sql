USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[CLIENT_MEMO_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[CLIENT_MEMO_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_GET]
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
		ID_DOC_TYPE, ID_SERVICE, ID_VENDOR, START, FINISH,
		MONTH_PRICE, PERIOD_PRICE, PERIOD_START, PERIOD_FINISH, PERIOD_FULL_PRICE,
		ID_PAY_TYPE, ID_CONTRACT_PAY, FRAMEWORK, DOCUMENTS, LETTER_CANCEL,
		SYSTEMS,
		(
			SELECT COMMENT
			FROM
				(
					SELECT ORD, (CONDITION + CHAR(13)) AS COMMENT
					FROM Memo.ClientMemoConditions b
					WHERE a.ID = b.ID_MEMO
				) AS o_O
			ORDER BY ORD FOR XML PATH(''), TYPE
		).value('.', 'nvarchar(max)') AS CONDITION
	FROM Memo.ClientMemo a
	WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_GET] TO rl_client_memo_r;
GO
