USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[BILL_DATE_DELETE]
	@date SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON
    
    DELETE 
    FROM 
    	dbo.BillDistrTable
    WHERE 
    	BD_DATE <= @date AND
    	NOT EXISTS
        	(
            	SELECT * 
                FROM 
                	dbo.IncomeDistrTable INNER JOIN
                	dbo.IncomeTable ON IN_ID = ID_ID_INCOME,
                    dbo.BillTable
                WHERE ID_ID_PERIOD = BL_ID_PERIOD 
                	AND ID_ID_DISTR = BD_ID_DISTR
                    AND IN_ID_CLIENT = BL_ID_CLIENT
					AND BL_ID = BD_ID_BILL
            )
            
    DELETE 
    FROM dbo.BillTable
    WHERE NOT EXISTS
    		(
            	SELECT * 
                FROM dbo.BillDistrTable
                WHERE BL_ID = BD_ID_BILL
            )
END
