USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_DOCUMENTS]
	@Contract_Id	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RowIndex, Type_Id, Date, Note
	FROM Contract.ClientContractsDocuments
	WHERE Contract_Id = @Contract_Id
	ORDER BY Date DESC;
END
