USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[DistrTypes:Coef@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[DistrTypes:Coef@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Price].[DistrTypes:Coef@Get]
(
	@Date	SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[DistrType_Id]	= D.[DistrTypeID],
		[Date]			= C.[Date],
		[Coef]			= C.[Coef],
		[Round]			= C.[Round]
	FROM [dbo].[DistrTypeTable] AS D
	CROSS APPLY
	(
		SELECT TOP (1)
			C.[Date],
			C.[Coef],
			C.[Round]
		FROM [Price].[DistrType:Coef] AS C
		WHERE C.[DistrType_Id] = D.[DistrTypeID]
			AND C.[Date] <= @Date
		ORDER BY C.[Date] DESC
	) AS C
)
GO
