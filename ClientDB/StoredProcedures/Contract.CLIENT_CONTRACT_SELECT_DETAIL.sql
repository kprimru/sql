USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT_DETAIL]
	@Contract_Id	UniqueIdentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DATE, ExpireDate, Type_Id, PayType_Id, Discount_Id, ContractPrice, Comments
	FROM Contract.ClientContractsDetails
	WHERE Contract_Id = @Contract_Id;
END
