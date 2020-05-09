USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[DAY_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, SHORT, NUM
	FROM Common.Day
	ORDER BY NUM
END
GO
GRANT EXECUTE ON [Common].[DAY_SELECT] TO public;
GO