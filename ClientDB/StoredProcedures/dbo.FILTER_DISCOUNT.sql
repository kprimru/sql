USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FILTER_DISCOUNT]
	@discountid INT,
	@contracttypeid INT,
	@startdate SMALLDATETIME,
	@enddate SMALLDATETIME,
	@managerid INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.ClientID, ClientFullName, ContractNumber, 
		ContractBegin, ContractTypeName, DiscountValue
	FROM
		dbo.ClientReadList()
		INNER JOIN dbo.ContractTable a ON ClientID = RCL_ID 
		INNER JOIN dbo.ClientTable b ON a.ClientID = b.ClientID 		
		LEFT OUTER JOIN dbo.DiscountTable c ON a.DiscountID = c.DiscountID 
		LEFT OUTER JOIN dbo.ContractTypeTable d ON d.ContractTypeID = a.ContractTypeID
	WHERE 
		(a.ContractTypeID = @contracttypeid OR @contracttypeid IS NULL) 
		AND (a.DiscountID = @discountid OR @discountid IS NULL) 
		AND (a.ContractBegin >= @startdate OR @startdate IS NULL)
		AND (a.ContractBegin <= @enddate OR @enddate IS NULL)
	ORDER BY DiscountOrder, ClientFullName
END