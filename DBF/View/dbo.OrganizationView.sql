USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[OrganizationView]
AS
	SELECT
		ORG_ID, ORG_SHORT_NAME, ORG_PSEDO, ORG_FULL_NAME,
		ORG_INDEX, a.ST_PREFIX, a.ST_NAME, a.CT_PREFIX, a.CT_NAME, ORG_HOME,
		CASE ORG_ID
			WHEN 1 THEN '690002, край Приморский, город Владивосток, проспект Острякова, дом 8'
			--WHEN 7 THEN '600002, край Приморский, город Владивосток, проспект Острякова, дом 8'
			WHEN 7 THEN '690078, край Приморский, город Владивосток, улица Садовая, дом 27'
			ELSE (ORG_INDEX + ', ' + a.CT_PREFIX + a.CT_NAME + ', ' + a.ST_PREFIX + a.ST_NAME + ',' + ORG_HOME)
		END AS ORG_ADDRESS,
		ORG_S_INDEX, b.ST_PREFIX AS ST_S_PREFIX, b.ST_NAME AS ST_S_NAME,
		b.CT_PREFIX AS CT_S_PREFIX, b.CT_NAME AS CT_S_NAME, ORG_S_HOME,
		ORG_PHONE,
		ORG_ACCOUNT, ORG_LORO, ORG_BIK, ORG_INN, ORG_KPP, ORG_OKONH, ORG_OKPO,
		ORG_BUH_FAM, ORG_BUH_NAME, ORG_BUH_OTCH,
		(ORG_BUH_FAM + ' ' + LEFT(ORG_BUH_NAME, 1) + '.' + LEFT(ORG_BUH_OTCH, 1) + '.') AS ORG_BUH_SHORT,
		ORG_DIR_FAM, ORG_DIR_NAME, ORG_DIR_OTCH,
		(ORG_DIR_FAM + ' ' + LEFT(ORG_DIR_NAME, 1) + '.' + LEFT(ORG_DIR_OTCH, 1) + '.') AS ORG_DIR_SHORT

	FROM
		dbo.OrganizationTable LEFT OUTER JOIN
		dbo.AddressView a ON a.ST_ID = ORG_ID_STREET LEFT OUTER JOIN
		dbo.AddressView b ON b.ST_ID = ORG_S_ID_STREET
