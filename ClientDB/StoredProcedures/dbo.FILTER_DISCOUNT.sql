USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FILTER_DISCOUNT]
	@discountid			Int,
	@contracttypeid		Int,
	@startdate			SmallDateTime,
	@enddate			SmallDateTime,
	@managerid			Int				= NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		CL.ClientID, ClientFullName, ContractNumber = NUM_S, 
		ContractBegin = DateFrom, ContractTypeName, DiscountValue
	FROM dbo.ClientReadList()			R
	INNER JOIN Contract.ClientContracts	CC	ON CC.Client_Id = R.RCL_ID 
	INNER JOIN Contract.Contract		C	ON C.ID = CC.Contract_Id
	CROSS APPLY
	(
		SELECT TOP (1) PayType_Id, Discount_Id, Type_Id
		FROM Contract.ClientContractsDetails D
		WHERE D.Contract_Id = C.ID
		ORDER BY DATE DESC
	) CD
	INNER JOIN dbo.ClientTable CL ON CL.ClientID = R.RCL_ID
	LEFT JOIN dbo.DiscountTable D ON D.DiscountID = CD.Discount_Id
	LEFT JOIN dbo.ContractTypeTable T ON T.ContractTypeID = CD.Type_Id
	WHERE
			(CD.Type_Id = @contracttypeid	OR @contracttypeid IS NULL) 
		AND (CD.Discount_ID = @discountid	OR @discountid IS NULL) 
		AND (C.DateFrom >= @startdate		OR @startdate IS NULL)
		AND (C.DateFrom <= @enddate			OR @enddate IS NULL)
	ORDER BY DiscountOrder, ClientFullName
END