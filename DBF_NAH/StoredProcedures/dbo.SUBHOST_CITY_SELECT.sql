USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[SUBHOST_CITY_SELECT]
	@active BIT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SC_ID, SH_SHORT_NAME, SH_ID, CT_NAME, CT_ID, MA_ID, MA_SHORT_NAME
	FROM
		dbo.SubhostCityTable a INNER JOIN
		dbo.SubhostTable b ON a.SC_ID_SUBHOST = b.SH_ID INNER JOIN
		dbo.CityTable c ON c.CT_ID = a.SC_ID_CITY INNER JOIN
		dbo.MarketAreaTable d ON d.MA_ID = a.SC_ID_MARKET_AREA
	WHERE SC_ACTIVE = ISNULL(@active, SC_ACTIVE)
	ORDER BY SH_SHORT_NAME, CT_NAME
END


GO
GRANT EXECUTE ON [dbo].[SUBHOST_CITY_SELECT] TO rl_subhost_city_r;
GO