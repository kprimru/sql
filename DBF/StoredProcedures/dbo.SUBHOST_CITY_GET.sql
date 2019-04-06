USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[SUBHOST_CITY_GET] 
	@subhostcityid INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT SC_ID, SH_SHORT_NAME, SH_ID, CT_NAME, CT_ID, MA_ID, MA_SHORT_NAME, SC_ACTIVE
	FROM 
		dbo.SubhostCityTable a INNER JOIN
		dbo.SubhostTable b ON a.SC_ID_SUBHOST = b.SH_ID INNER JOIN
		dbo.CityTable c ON c.CT_ID = a.SC_ID_CITY INNER JOIN
		dbo.MarketAreaTable d ON d.MA_ID = a.SC_ID_MARKET_AREA
	WHERE SC_ID = @subhostcityid

	SET NOCOUNT OFF
END








