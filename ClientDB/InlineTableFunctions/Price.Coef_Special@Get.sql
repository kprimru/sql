USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Coef:Special@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[Coef:Special@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [Price].[Coef:Special@Get]
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
		[SystemType_Id]	= D.[SystemType_Id],
		[Date]			= C.[Date],
		[Coef]			= C.[Coef],
		[Round]			= C.[Round]
	FROM
	(
		SELECT DISTINCT [System_Id], [DistrType_Id], [SystemType_Id]
		FROM [Price].[Coef:Special] AS D
	) AS D
	CROSS APPLY
	(
		SELECT TOP (1)
			C.[Date],
			C.[Coef],
			C.[Round]
		FROM [Price].[Coef:Special] AS C
		WHERE C.[System_Id] = D.[System_Id]
			AND C.[DistrType_Id] = D.[DistrType_Id]
			AND C.[SystemType_Id] = D.[SystemType_Id]
			AND C.[Date] <= @Date
		ORDER BY C.[Date] DESC
	) AS C
)
GO
