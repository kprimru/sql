USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_MASTER_PRINT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_MASTER_PRINT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_MASTER_PRINT]
	@ACT INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		A.ProviderName, ProviderCity, A.ProviderDistributor, ActYear,
		TaxName, TaxRate, TotalTaxPrice, TotalPrice, TotalPrice + TotalTaxPrice AS Total, TotalStr,
		A.ProviderDirector, A.ProviderDirectorRod, IsNull(P.ProviderDirectorPosition, 'Директор') AS ProviderDirectorPosition,
		IsNull(P.ProviderDirectorPositionRod, 'директора') AS ProviderDirectorPositionRod,
		IsNull(P.ProviderPurpose, 'устава') AS ProviderPurpose,
		A.ProviderFullName, CustomerName
	FROM ActTable AS A WITH(NOLOCK)
	LEFT JOIN ProviderTable AS P ON A.ProviderName = P.ProviderName
	WHERE ActID = @ACT
END
GO
GRANT EXECUTE ON [dbo].[ACT_MASTER_PRINT] TO DBCount;
GO
