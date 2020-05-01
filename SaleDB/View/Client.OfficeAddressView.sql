USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Client].[OfficeAddressView]
AS
	SELECT
		z.ID_COMPANY AS CO_ID, a.ID, ID_OFFICE,
		b.NAME AS AR_NAME,
		CASE ISNULL(d.DISPLAY, 1) WHEN 1 THEN ISNULL(d.PREFIX, '') + ISNULL(d.NAME + ', ', '') ELSE '' END + ISNULL(c.PREFIX, '') + ISNULL(c.NAME + ' ', '') + ISNULL(c.SUFFIX + ' ', '') + ISNULL(HOME + ', ', '') + ISNULL(ROOM, '') AS AD_STR,
		NOTE, MAIN,
		b.ID AS AR_ID, c.ID AS ST_ID, ROOM, HOME
	FROM
		Client.Office z
		INNER JOIN Client.OfficeAddress a ON z.ID = a.ID_OFFICE
		LEFT OUTER JOIN Address.Area b ON a.ID_AREA = b.ID
		LEFT OUTER JOIN Address.Street c ON a.ID_STREET = c.ID
		LEFT OUTER JOIN Address.City d ON c.ID_CITY = d.ID