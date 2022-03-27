USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[Complect@Online Count]', 'IF') IS NULL EXEC('CREATE FUNCTION [Reg].[Complect@Online Count] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [Reg].[Complect@Online Count]
(
	@Complect	VarChar(100)
)
RETURNS TABLE
AS
RETURN
(
	SELECT MAIN.[MainQuantity], AD.[AdditionalQuantity]
	FROM
	(
		SELECT TOP (1)
			[System]	= Cast([Reg].[Complect@Extract?Params](@Complect, 'SYSTEM') AS VarChar(100)),
			[Distr]		= Cast([Reg].[Complect@Extract?Params](@Complect, 'DISTR') AS Int),
			[Comp]		= Cast([Reg].[Complect@Extract?Params](@Complect, 'COMP') As TinyInt)
	) AS D
	CROSS APPLY
	(
		SELECT TOP (1)
			[MainQuantity] = O.[Quantity]
		FROM [Reg].[RegNodeSearchView] AS R WITH(NOEXPAND)
		INNER JOIN [dbo].[OnlineRules] AS O ON O.[System_Id] = R.[SystemID] AND O.[DistrType_Id] = R.[DistrTypeId]
		WHERE R.[SystemBaseName] = D.[System]
			AND R.[DistrNumber] = D.[Distr]
			AND R.[CompNumber] = D.[Comp]
			AND R.[DS_REG] = 0
	) AS MAIN
	CROSS APPLY
	(
		SELECT
			[AdditionalQuantity] = Sum(O.[Quantity])
		FROM [Reg].[RegNodeSearchView] AS R WITH(NOEXPAND)
		INNER JOIN [dbo].[OnlineRules] AS O ON O.[System_Id] = R.[SystemID] AND O.[DistrType_Id] = R.[DistrTypeId]
		WHERE R.[Complect] = @Complect
			AND R.[DS_REG] = 0
			AND R.[SystemBaseName] != D.[System]
	) AS AD
)GO
