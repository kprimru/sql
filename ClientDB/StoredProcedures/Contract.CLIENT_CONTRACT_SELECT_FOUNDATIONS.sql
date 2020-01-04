USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_FOUNDATIONS]
	@Contract_Id	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DATE, Foundation_Id, ExpireDate, Note
	FROM Contract.ClientContractsFoundations
	WHERE Contract_Id = @Contract_Id
	ORDER BY Date DESC;
END
