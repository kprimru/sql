USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ClientDistrView]
AS
SELECT 
		CD_ID, CD_ID_DISTR, CD_ID_CLIENT, CD_REG_DATE, DIS_NUM, DIS_ID, DIS_COMP_NUM, 
		SYS_ORDER, SYS_SHORT_NAME, SYS_REG_NAME, SYS_ID, DSS_NAME, DSS_ID, DSS_REPORT, 
		DIS_STR, SYS_ID_SO,	DIS_ACTIVE
	FROM  
		dbo.ClientDistrTable AS a INNER JOIN
        dbo.DistrView AS b WITH(NOEXPAND) ON a.CD_ID_DISTR = b.DIS_ID LEFT OUTER JOIN
        dbo.DistrServiceStatusTable AS c ON a.CD_ID_SERVICE = c.DSS_ID
