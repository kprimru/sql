USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RegNodeSubhostView]
AS
	SELECT
		RNS_ID,
		SH_ID, SH_SHORT_NAME,
		PR_ID, PR_DATE,
		d.SYS_ID, d.SYS_SHORT_NAME, d.SYS_ORDER,
		SST_ID, SST_CAPTION,
		TT_ID, TT_NAME,
		g.SN_ID, g.SN_NAME,
		RNS_DISTR, RNS_COMP, RNS_COMMENT,
		CASE RNS_COMP
			WHEN 1 THEN d.SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), RNS_DISTR)
			ELSE d.SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), RNS_DISTR) + '/' + CONVERT(VARCHAR(20), RNS_COMP)
		END AS DIS_STR,
		h.SYS_ID AS SYS_OLD_ID, h.SYS_SHORT_NAME AS SYS_OLD_NAME,
		i.SYS_ID AS SYS_NEW_ID, i.SYS_SHORT_NAME AS SYS_NEW_NAME,
		j.SN_ID AS SN_OLD_ID, j.SN_NAME AS SN_OLD_NAME,
		k.SN_ID AS SN_NEW_ID, k.SN_NAME AS SN_NEW_NAME
	FROM
		dbo.RegNodeSubhostTable a INNER JOIN
		dbo.SubhostTable b ON a.RNS_ID_HOST = b.SH_ID INNER JOIN
		dbo.PeriodTable c ON a.RNS_ID_PERIOD = c.PR_ID INNER JOIN
		dbo.SystemTable d ON a.RNS_ID_SYSTEM = d.SYS_ID INNER JOIN
		dbo.SystemTypeTable e ON a.RNS_ID_TYPE = e.SST_ID INNER JOIN
		dbo.TechnolTypeTable f ON a.RNS_ID_TECH = f.TT_ID INNER JOIN
		dbo.SystemNetTable g ON a.RNS_ID_NET = g.SN_ID LEFT OUTER JOIN
		dbo.SystemTable h ON a.RNS_ID_OLD_SYS = h.SYS_ID LEFT OUTER JOIN
		dbo.SystemTable i ON a.RNS_ID_NEW_SYS = i.SYS_ID LEFT OUTER JOIN
		dbo.SystemNetTable j ON a.RNS_ID_OLD_NET = j.SN_ID LEFT OUTER JOIN
		dbo.SystemNetTable k ON a.RNS_ID_NEW_NET = k.SN_ID