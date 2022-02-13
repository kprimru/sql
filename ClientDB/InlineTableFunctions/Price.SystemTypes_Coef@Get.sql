USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[SystemTypes:Coef@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[SystemTypes:Coef@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [Price].[SystemTypes:Coef@Get]
(
	@Date	SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[SystemType_Id]	= D.[SystemTypeID],
		[Date]			= C.[Date],
		[Coef]			= C.[Coef],
		[Round]			= C.[Round]
	FROM [dbo].[SystemTypeTable] AS D
	CROSS APPLY
	(
		SELECT TOP (1)
			C.[Date],
			C.[Coef],
			C.[Round]
		FROM [Price].[SystemType:Coef] AS C
		WHERE C.[SystemType_Id] = D.[SystemTypeID]
			AND C.[Date] <= @Date
		ORDER BY C.[Date] DESC
	) AS C
)
GO
