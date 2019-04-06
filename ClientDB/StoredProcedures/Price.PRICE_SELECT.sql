USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[PRICE_SELECT]
	@MONTH	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SystemID, SystemShortName, PRICE
	FROM
		Price.SystemPrice
		INNER JOIN dbo.SystemTable ON SystemID = ID_SYSTEM
	WHERE ID_MONTH = @MONTH
	ORDER BY SystemOrder
END