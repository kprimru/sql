USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[PRICE_TOTAL_SHOW] 
	@priceid INT,
	@periodid INT
AS
BEGIN
	SET NOCOUNT ON

	IF 
		@priceid IS NULL AND
		@periodid IS NOT NULL
		BEGIN
			SELECT 
				0 AS PP_GROUP, PR_DATE, PP_NAME, SYS_SHORT_NAME, SYS_ORDER,
				CAST(PS_PRICE * PP_COEF_MUL + PP_COEF_ADD AS MONEY) AS PP_PRICE
			FROM 
				dbo.PriceTable a INNER JOIN
				dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID INNER JOIN
				dbo.PriceSystemTable c ON c.PS_ID_TYPE = b.PT_ID INNER JOIN
				dbo.PeriodTable d ON d.PR_ID = c.PS_ID_PERIOD INNER JOIN
				dbo.SystemTable e ON e.SYS_ID = c.PS_ID_SYSTEM LEFT OUTER JOIN
				dbo.PriceSystemHistoryTable f ON 
											f.PSH_ID_SYSTEM = e.SYS_ID AND 
											f.PSH_ID_PERIOD = d.PR_ID
			WHERE PR_ID = @periodid    
   
			UNION ALL
  
			SELECT 
				1 AS PP_GROUP, NULL AS PR_DATE, PP_NAME, '' AS SYS_SHORT_NAME, 0 AS SYS_ORDER,
				NULL AS PP_PRICE
			FROM dbo.PriceTable
			ORDER BY PP_NAME, PR_DATE, SYS_ORDER, SYS_SHORT_NAME
		END
	ELSE IF @priceid IS NOT NULL AND
			@periodid IS NULL 
		BEGIN
			SELECT 
				0 AS PP_GROUP, PR_DATE, PP_NAME, SYS_SHORT_NAME, SYS_ORDER, 
				CAST(PS_PRICE * PP_COEF_MUL + PP_COEF_ADD AS MONEY) AS PP_PRICE
			FROM 
				dbo.PriceTable a INNER JOIN
				dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID INNER JOIN
				dbo.PriceSystemTable c ON c.PS_ID_TYPE = b.PT_ID INNER JOIN
				dbo.PeriodTable d ON d.PR_ID = c.PS_ID_PERIOD INNER JOIN
				dbo.SystemTable e ON e.SYS_ID = c.PS_ID_SYSTEM LEFT OUTER JOIN
				dbo.PriceSystemHistoryTable f ON 
											f.PSH_ID_SYSTEM = e.SYS_ID AND 
											f.PSH_ID_PERIOD = d.PR_ID
			WHERE PP_ID = @priceid    
   
			UNION ALL
  
			SELECT 
				1 AS PP_GROUP, PR_DATE, '' AS PP_NAME, '' AS SYS_SHORT_NAME, 0 AS SYS_ORDER,
				NULL AS PP_PRICE
			FROM dbo.PeriodTable
			WHERE 
				(
					SELECT COUNT(*) 
					FROM dbo.PriceSystemTable
					WHERE PS_ID_PERIOD = PR_ID
				) <> 0
			ORDER BY PR_DATE, PP_NAME, SYS_ORDER, SYS_SHORT_NAME
		END
	ELSE IF @priceid IS NOT NULL AND
			@periodid IS NOT NULL
		BEGIN
			SELECT 
				0 AS PP_GROUP, PR_DATE, PP_NAME, SYS_SHORT_NAME,
				CAST(PS_PRICE * PP_COEF_MUL + PP_COEF_ADD AS MONEY) AS PP_PRICE, 
				PSH_DOC_COUNT    
			FROM 
				dbo.PriceTable a INNER JOIN
				dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID INNER JOIN
				dbo.PriceSystemTable c ON c.PS_ID_TYPE = b.PT_ID INNER JOIN
				dbo.PeriodTable d ON d.PR_ID = c.PS_ID_PERIOD INNER JOIN
				dbo.SystemTable e ON e.SYS_ID = c.PS_ID_SYSTEM LEFT OUTER JOIN
				dbo.PriceSystemHistoryTable f ON 
										f.PSH_ID_SYSTEM = e.SYS_ID AND 
										f.PSH_ID_PERIOD = d.PR_ID
			WHERE PP_ID = @priceid AND PR_ID = @periodid
			ORDER BY SYS_ORDER, SYS_SHORT_NAME
		END

	SET NOCOUNT OFF
END


















