USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SaldoLastDateView]
AS
  SELECT DISTINCT
		CL_ID, DIS_ID, CL_PSEDO, DIS_STR, SN_ID, SN_NAME, SL_DATE,
		ISNULL(
        	(
    			SELECT TOP 1 SL_REST 
	        	FROM dbo.SaldoView b
		        WHERE b.SL_ID_DISTR = a.SL_ID_DISTR	
    		    	AND b.SL_ID_CLIENT = a.SL_ID_CLIENT
					AND b.SL_DATE <= a.SL_DATE
        		ORDER BY SL_DATE DESC, SL_TP, SL_ID DESC
		    ), 0) AS SL_REST
	FROM 
		dbo.SaldoTable a INNER JOIN
	    dbo.ClientTable ON CL_ID = SL_ID_CLIENT INNER JOIN
    	dbo.DistrView ON DIS_ID = SL_ID_DISTR LEFT OUTER JOIN
        dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID LEFT OUTER JOIN
        dbo.SystemNetTable ON SN_ID = DF_ID_NET
