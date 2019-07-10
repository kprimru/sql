USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BillIXView]
WITH SCHEMABINDING
AS
	SELECT BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR, SUM(BD_TOTAL_PRICE) AS BD_TOTAL_PRICE, COUNT_BIG(*) AS BD_CNT
	FROM        
		dbo.BillDistrTable INNER JOIN
        dbo.BillTable ON BD_ID_BILL = BL_ID
	GROUP BY BL_ID_CLIENT, BL_ID_PERIOD, BD_ID_DISTR