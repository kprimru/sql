USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Coef:Special:Common@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[Coef:Special:Common@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE OR ALTER FUNCTION [Price].[Coef:Special:Common@Get]
(
	@Date	SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[System_Id]		= D.[System_Id],
		[DistrType_Id]	= D.[DistrType_Id],
		[Date]			= C.[Date],
		[Coef]			= C.[Coef],
		[Round]			= C.[Round]
	FROM
	(
		SELECT DISTINCT [System_Id], [DistrType_Id]
		FROM [Price].[Coef:Special:Common] AS D
	) AS D
	CROSS APPLY
	(
		SELECT TOP (1)
			C.[Date],
			C.[Coef],
			C.[Round]
		FROM [Price].[Coef:Special:Common] AS C
		WHERE C.[System_Id] = D.[System_Id]
			AND C.[DistrType_Id] = D.[DistrType_Id]
			AND C.[Date] <= @Date
		ORDER BY C.[Date] DESC
	) AS C
)
GO
