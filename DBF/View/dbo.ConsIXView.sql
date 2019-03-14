USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[ConsIXView]
WITH SCHEMABINDING
AS
	SELECT CSG_ID_CLIENT, CSD_ID_PERIOD, CSD_ID_DISTR, SUM(ISNULL(CSD_TOTAL_PRICE, 0)) AS CSD_TOTAL_PRICE, COUNT_BIG(*) AS CSD_CNT
	FROM        
		dbo.ConsignmentDetailTable INNER JOIN
        dbo.ConsignmentTable ON CSD_ID_CONS = CSG_ID
	GROUP BY CSG_ID_CLIENT, CSD_ID_PERIOD, CSD_ID_DISTR