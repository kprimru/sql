USE [BuhDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[ACT_MASTER_PRINT]
	@ACT INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ProviderName, ProviderCity, ProviderDistributor, ActYear, 
		TaxName, TaxRate, TotalTaxPrice, TotalPrice, TotalPrice + TotalTaxPrice AS Total, TotalStr, 
		ProviderDirector, ProviderDirectorRod, ProviderFullName 
	FROM ActTable WITH(NOLOCK) 
	WHERE ActID = @ACT
END
