USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTRACT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_SELECT]
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
			ContractID, ContractDate,
			ContractNumber, ContractYear,
			ContractNumber + ISNULL(' от ' + CONVERT(VARCHAR(20), ContractDate, 104), '') AS ContractNumberStr,
			ContractTypeName,
			ContractBegin, ContractEnd,
			ContractConditions,
			ContractPayName, DiscountValue, ContractFixed,
			ID_FOUNDATION, NAME, FOUND_END, FOUND_NOTE,
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM dbo.ContractDocument
						WHERE ID_CONTRACT = ContractID
							AND STATUS = 1
					) THEN
					'Изменяющих документов: ' + CONVERT(NVARCHAR(16), (
						SELECT COUNT(*)
						FROM dbo.ContractDocument
						WHERE ID_CONTRACT = ContractID
							AND STATUS = 1
					))
				ELSE 'Нет изменяющих документов'
			END AS DOCUMENT_LIST
		FROM
			dbo.ContractTable a
			INNER JOIN dbo.ContractTypeTable b ON a.ContractTypeID = b.ContractTypeID
			LEFT OUTER JOIN dbo.ContractPayTable c ON a.ContractPayID = c.ContractPayID
			LEFT OUTER JOIN dbo.DiscountTable d ON a.DiscountID = d.DiscountID
			LEFT OUTER JOIN dbo.ContractFoundation ON ID_FOUNDATION = ID
		WHERE ClientID = @CLIENT
		ORDER BY ContractBegin DESC, ContractID DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_SELECT] TO rl_client_contract_r;
GO
