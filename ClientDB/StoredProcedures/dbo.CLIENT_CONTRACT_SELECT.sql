USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

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
				'»змен€ющих документов: ' + CONVERT(NVARCHAR(16), (
					SELECT COUNT(*)
					FROM dbo.ContractDocument
					WHERE ID_CONTRACT = ContractID
						AND STATUS = 1
				))
			ELSE 'Ќет измен€ющих документов' 
		END AS DOCUMENT_LIST
	FROM 
		dbo.ContractTable a
		INNER JOIN dbo.ContractTypeTable b ON a.ContractTypeID = b.ContractTypeID
		LEFT OUTER JOIN dbo.ContractPayTable c ON a.ContractPayID = c.ContractPayID
		LEFT OUTER JOIN dbo.DiscountTable d ON a.DiscountID = d.DiscountID
		LEFT OUTER JOIN dbo.ContractFoundation ON ID_FOUNDATION = ID
	WHERE ClientID = @CLIENT
	ORDER BY ContractBegin DESC, ContractID DESC
END