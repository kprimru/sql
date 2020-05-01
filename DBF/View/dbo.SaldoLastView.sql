USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[SaldoLastView]
AS
  SELECT
		CL_ID, DIS_ID, CL_PSEDO, DIS_STR, SYS_ID_SO,
		ISNULL(
        	(
    			SELECT TOP 1 SL_REST 
	        	FROM dbo.SaldoView b
		        WHERE b.SL_ID_DISTR = a.SL_ID_DISTR	
    		    	AND b.SL_ID_CLIENT = a.SL_ID_CLIENT
        		ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
		    ), 0) AS SL_REST,
		ISNULL(
        	(
    			SELECT TOP 1 SL_BEZ_NDS 
	        	FROM dbo.SaldoView b
		        WHERE b.SL_ID_DISTR = a.SL_ID_DISTR	
    		    	AND b.SL_ID_CLIENT = a.SL_ID_CLIENT
        		ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
		    ), 0) AS SL_BEZ_NDS
	FROM 
		(
			SELECT DISTINCT SL_ID_CLIENT, SL_ID_DISTR
			FROM dbo.SaldoTable z
		) AS a INNER JOIN
	    dbo.ClientTable ON CL_ID = SL_ID_CLIENT INNER JOIN
    	dbo.DistrView WITH(NOEXPAND) ON DIS_ID = SL_ID_DISTR 
