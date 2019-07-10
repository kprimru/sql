USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/
CREATE PROCEDURE [dbo].[CLIENT_BILL_SELECT_NEW]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;
	

	DECLARE @bill TABLE
		(
			BL_ID INT, 		
			PR_ID SMALLINT, 
			BL_ID_CLIENT INT, 
			SO_ID SMALLINT,
			ORG_ID SMALLINT,
			BL_PRICE MONEY
		)

	INSERT INTO @bill(BL_ID, PR_ID, BL_ID_CLIENT, SO_ID, ORG_ID, BL_PRICE)
		SELECT 
			BL_ID, BL_ID_PERIOD, BL_ID_CLIENT, SYS_ID_SO, BL_ID_ORG, 
			ISNULL(SUM(BD_TOTAL_PRICE), 0)
		FROM 
			dbo.BillTable INNER JOIN
			dbo.BillDistrTable ON BL_ID = BD_ID_BILL INNER JOIN
			dbo.DistrView ON DIS_ID = BD_ID_DISTR
		WHERE BL_ID_CLIENT = @clientid
		GROUP BY BL_ID, BL_ID_PERIOD, BL_ID_CLIENT, SYS_ID_SO, BL_ID_ORG


	DECLARE @income TABLE
		(		
			BL_ID INT,
			PR_ID SMALLINT,
			SO_ID SMALLINT,
			IN_PRICE MONEY
		)

	INSERT INTO @income(BL_ID, PR_ID, SO_ID, IN_PRICE)
		SELECT BL_ID, PR_ID, a.SO_ID, SUM(ID_PRICE)
		FROM 
			dbo.IncomeDistrTable INNER JOIN
			dbo.IncomeTable ON ID_ID_INCOME = IN_ID INNER JOIN
			dbo.BillDistrTable ON ID_ID_DISTR = BD_ID_DISTR INNER JOIN		
			dbo.DistrView ON DIS_ID = ID_ID_DISTR INNER JOIN
			dbo.SaleObjectTable a ON a.SO_ID = SYS_ID_SO INNER JOIN
			@bill b ON b.PR_ID = ID_ID_PERIOD AND BD_ID_BILL = BL_ID AND BL_ID_CLIENT = IN_ID_CLIENT AND a.SO_ID = b.SO_ID
		GROUP BY BL_ID, PR_ID, a.SO_ID	

	SELECT 
    	BL_ID, PR_ID, PR_DATE, BL_PRICE, 
		(
        	ISNULL(
            	(
        			SELECT IN_PRICE
					FROM @income a
					WHERE a.BL_ID = b.BL_ID AND a.SO_ID = b.SO_ID
    	        ), 0)
        ) AS BL_PAY, 
        SO_NAME, SO_ID, 
		(
        	BL_PRICE - ISNULL(
            	(
        			SELECT IN_PRICE
					FROM @income a
					WHERE a.BL_ID = b.BL_ID AND a.SO_ID = b.SO_ID
    	        ), 0)
        ) AS BL_UNPAY, ORG_PSEDO
	FROM 
		(
			SELECT     
				BL_ID, PR_DATE, z.PR_ID, BL_ID_CLIENT, SO_NAME, z.SO_ID,
				BL_PRICE, z.ORG_ID, ORG_PSEDO
			FROM 
				@bill z INNER JOIN
				dbo.OrganizationTable y ON z.ORG_ID = y.ORG_ID INNER JOIN	
				dbo.PeriodTable x ON z.PR_ID = x.PR_ID INNER JOIN								
				dbo.SaleObjectTable t ON t.SO_ID = z.SO_ID
		) AS b
	ORDER BY PR_DATE DESC
END