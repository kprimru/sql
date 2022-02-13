USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[Systems:Price@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [Price].[Systems:Price@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [Price].[Systems:Price@Get]
(
	@Date	SmallDateTime
)
RETURNS TABLE
AS
RETURN
(
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
)
GO
