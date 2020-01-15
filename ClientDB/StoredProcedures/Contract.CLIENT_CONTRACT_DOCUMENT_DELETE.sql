USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_DOCUMENT_DELETE]
	@Contract_Id	UniqueIdentifier,
	@RowIndex		SmallInt
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM Contract.ClientContractsDocuments
	WHERE Contract_Id = @Contract_Id
		AND RowIndex = @RowIndex;
END
