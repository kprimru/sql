USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Systems:Price@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[Systems:Price@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE OR ALTER FUNCTION [Price].[Systems:Price@Get]
(
	@Date	SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[System_Id] = C.[System_Id],
		[Date]		= C.[Date],
		[Price]		= C.[Price]
	FROM
	(
		SELECT [PriceCoefVersion] = Cast([System].[Setting@Get]('PRICE_COEF_VERSION') AS SmallInt)
	) AS V
	OUTER APPLY
	(
		SELECT
			[System_Id] = S.[SystemID],
			[Date]		= @Date,
			[Price]		= P.[Price]
		FROM dbo.SystemTable AS S
		INNER JOIN Price.SystemPrice AS P ON P.ID_SYSTEM = S.SystemID
		INNER JOIN Common.Period AS PR ON PR.ID = P.ID_MONTH
		WHERE PR.START = @Date AND PR.TYPE = 2
			AND V.[PriceCoefVersion] = 1
		UNION ALL
		SELECT
			[System_Id] = S.[SystemID],
			[Date]		= P.[Date],
			[Price]		= P.[Price]
		FROM dbo.SystemTable AS S
		CROSS APPLY
		(
			SELECT TOP (1)
				P.[Date],
				P.[Price]
			FROM [Price].[System:Price] AS P
			WHERE P.[System_Id] = S.[SystemID]
				AND P.[Date] <= @Date
			ORDER BY P.[Date] DESC
		) AS P
		WHERE V.[PriceCoefVersion] = 2
		UNION ALL
		SELECT
			[System_Id] = NULL,
			[Date]		= NULL,
			[Price]		= 0
		WHERE V.[PriceCoefVersion] NOT IN (1, 2)
	) AS C
)
GO
