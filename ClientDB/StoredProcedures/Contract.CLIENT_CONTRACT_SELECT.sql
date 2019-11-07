USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Contract].[CLIENT_CONTRACT_SELECT]
	@ClientId	Int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT C.ID, C.NUM_S, DateFrom, DateTo, ExpireDate, Type_Id, PayType_Id, Discount_Id, ContractPrice, Comments
	FROM Contract.ClientContracts	CC
	INNER JOIN Contract.Contract	C	ON C.ID = CC.Contract_Id
	CROSS APPLY
	(
		SELECT TOP (1) ExpireDate, Type_Id, PayType_Id, Discount_Id, ContractPrice, Comments
		FROM Contract.ClientContractsDetails CCD
		WHERE CCD.Contract_Id = CC.Contract_Id
		ORDER BY CCD.DATE DESC
	) D
	WHERE CC.Client_Id = @ClientId
	ORDER BY DateFrom DESC
END
