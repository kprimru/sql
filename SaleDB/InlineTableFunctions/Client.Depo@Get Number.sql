USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Client].[Depo@Get Number]()
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (1) [Number]
	FROM
	(
		SELECT TOP (1)
			[Ord]		= 1,
			[Number]	= Max(D.[Number]) + 1
		FROM Client.CompanyDepo AS D

		UNION ALL

		SELECT
			[Ord]		= 2,
			[Number]	= 1
	) AS N
	ORDER BY [Ord]
)
GO
