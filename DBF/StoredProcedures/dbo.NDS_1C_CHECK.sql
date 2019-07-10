USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NDS_1C_CHECK]
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

	
	SELECT CLIENT, 'Отсутствует клиент в ДБФ' AS ERR
	FROM 
		(
			SELECT DISTINCT CLIENT
			FROM dbo.NDS1CDetail
			WHERE ID_MASTER = @ID				
				AND 
					(
						(TP IN ('51', '50') AND  ISNULL(PRICE2, 0) <> 0)
						OR 
						(TP = '76' AND ISNULL(PRICE , 0) <> 0)
					)
		) AS c
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientTable
			WHERE CL_1C = CLIENT
		)
		
	UNION ALL
	
	SELECT CL_1C, 'Отсутствует клиент в 1С'
	FROM
		(
			SELECT DISTINCT CL_1C
			FROM 
				(
					SELECT CL_1C
					FROM 
						dbo.BookSale
						INNER JOIN dbo.InvoiceSaleTable ON INS_ID = ID_INVOICE
						INNER JOIN dbo.ClientTable ON INS_ID_CLIENT = CL_ID
					WHERE DATE BETWEEN @PR_BEGIN AND @PR_END
					
					UNION
					
					SELECT CL_1C
					FROM 
						dbo.BookPurchase
						INNER JOIN dbo.InvoiceSaleTable ON INS_ID = ID_AVANS
						INNER JOIN dbo.ClientTable ON INS_ID_CLIENT = CL_ID
					WHERE PURCHASE_DATE BETWEEN @PR_BEGIN AND @PR_END
				) AS o_O
		) AS a
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.NDS1CDetail
			WHERE ID_MASTER = @ID 
				AND TP IN ('76', '51', '50')
		)
END
