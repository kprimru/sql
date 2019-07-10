USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Описание:		
*/
CREATE PROCEDURE [dbo].[CLIENT_SALDO_LAST_SELECT] 
	@clientid INT,
	@date SMALLDATETIME = NULL	
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT --DISTINCT
		CL_ID, DIS_ID, CL_PSEDO, DIS_STR, SN_ID, SN_NAME,
		ISNULL(
        	(
    			SELECT TOP 1 SL_REST 
	        	FROM dbo.SaldoView b
		        WHERE b.SL_ID_DISTR = a.SL_ID_DISTR	
    		    	AND b.SL_ID_CLIENT = a.SL_ID_CLIENT
					AND SL_DATE <= @date
        		ORDER BY SL_DATE DESC, SL_TP DESC, SL_ID DESC
		    ), 0) AS SL_REST
	FROM 
		(
			SELECT DISTINCT SL_ID_CLIENT, SL_ID_DISTR 
			FROM dbo.SaldoTable 
			WHERE SL_ID_CLIENT = @clientid AND SL_DATE <= @date
		) a INNER JOIN
	    dbo.ClientTable ON CL_ID = SL_ID_CLIENT INNER JOIN
    	dbo.DistrView ON DIS_ID = SL_ID_DISTR LEFT OUTER JOIN
        dbo.DistrFinancingTable ON DF_ID_DISTR = DIS_ID LEFT OUTER JOIN
        dbo.SystemNetTable ON SN_ID = DF_ID_NET
	WHERE CL_ID = @clientid
	ORDER BY SYS_ORDER, DIS_STR

END