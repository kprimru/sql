USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_GET]
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
			DATE, Contract_Id,
			CURRENT_CONTRACT, DISTR, ID_DOC_TYPE, ID_SERVICE, ID_VENDOR, START, FINISH,
			MONTH_PRICE, PERIOD_PRICE, PERIOD_START, PERIOD_END, PERIOD_FULL_PRICE,
			ID_PAY_TYPE, ID_CONTRACT_PAY_TYPE, FRAMEWORK, DOCUMENTS, LETTER_CANCEL,
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
			).value('.', 'nvarchar(max)') AS CONDITION,
			(
			    SELECT '{' + Cast(S.[Specification_Id] AS VarChar(100)) + '}'
			    FROM Memo.ClientMemoSpecifications AS S
			    WHERE S.[Memo_Id] = A.ID
			    FOR XML PATH('ITEM'), ROOT('LIST')
			) AS SPECIFICATIONS,
			(
			    SELECT '{' + Cast(S.[Additional_Id] AS VarChar(100)) + '}'
			    FROM Memo.ClientMemoAdditionals AS S
			    WHERE S.[Memo_Id] = A.ID
			    FOR XML PATH('ITEM'), ROOT('LIST')
			) AS ADDITIONALS
		FROM Memo.ClientMemo AS A
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_GET] TO rl_client_memo_r;
GO
