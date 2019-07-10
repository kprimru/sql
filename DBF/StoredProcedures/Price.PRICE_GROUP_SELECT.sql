USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[PRICE_GROUP_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT PT_GROUP, MIN(PT_ORDER) AS ORD
	FROM Price.PriceType
	GROUP BY PT_GROUP
	ORDER BY ORD
END
