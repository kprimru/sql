USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NDS_1C_SALE]
	@ORG	SMALLINT,
	@TAX	SMALLINT,
	@PERIOD	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ID	UNIQUEIDENTIFIER

	SELECT @ID = ID
	FROM dbo.NDS1C
	WHERE ID_ORG = @ORG
		AND ID_TAX = @TAX
		AND ID_PERIOD = @PERIOD
		
	DECLARE @PR_BEGIN	SMALLDATETIME
	DECLARE @PR_END		SMALLDATETIME

	SELECT @PR_BEGIN = PR_DATE, @PR_END = PR_END_DATE
	FROM dbo.PeriodTable
	WHERE PR_ID = @PERIOD

	IF OBJECT_ID('tempdb..#nds') IS NOT NULL
		DROP TABLE #nds

	IF OBJECT_ID('tempdb..#c')	 IS NOT NULL
		DROP TABLE #c
		
	SELECT CLIENT, /*SUM(PRICE) AS PRICE, */SUM(PRICE2) AS PRICE2
	INTO #c
	FROM dbo.NDS1CDetail
	WHERE (TP = '50' OR TP = '51') AND ID_MASTER = @ID AND ISNULL(PRICE2, 0) <> 0
	GROUP BY CLIENT

	SELECT CL_1C, SUM(NDS) AS NDS
		INTO #nds
	FROM
		(
			SELECT 
				NUM, DATE, ISNULL(CL_1C, '!!!��� �������!!!') AS CL_1C, 
				(
					SELECT SUM(ROUND(S_NDS, 2))
					FROM dbo.BookSaleDetail b
					WHERE a.ID = b.ID_SALE
						AND b.ID_TAX = @TAX
				) AS NDS
			FROM 
				dbo.BookSale a
				INNER JOIN dbo.InvoiceSaleTable c ON c.INS_ID = a.ID_INVOICE
				LEFT OUTER JOIN dbo.ClientTable ON c.INS_ID_CLIENT = CL_ID
			WHERE DATE BETWEEN @PR_BEGIN AND @PR_END
				AND ID_ORG = @ORG
				AND CODE = '02'
		) AS o_O
	WHERE ISNULL(NDS, 0)  <> 0
	GROUP BY CL_1C	
			
	SELECT CLIENT, PRICE2 AS [1C_PRICE], NDS AS [DBF_PRICE], PRICE2 - NDS AS [DIFF]
	FROM 
		#c a
		INNER JOIN #nds b ON a.CLIENT = b.CL_1C
	WHERE a.PRICE2 <> b.NDS
	
	UNION ALL
	
	SELECT CL_1C, 0 AS [1C_PRICE], NDS AS [DBF_PRICE], NDS AS [DIFF]
	FROM 
		#nds b 
	WHERE NDS <> 0 AND 
		NOT EXISTS
		(
			SELECT *
			FROM #c a
			WHERE a.CLIENT = b.CL_1C
		)
	
	UNION ALL
	
	SELECT CLIENT, PRICE2 AS [1C_PRICE], 0 AS [DBF_PRICE], PRICE2 AS [DIFF]
	FROM 
		#c a		
	WHERE PRICE2 <> 0
		AND NOT EXISTS
		(
			SELECT *
			FROM #nds b
			WHERE a.CLIENT = b.CL_1C
		)
	
	ORDER BY CLIENT
END
