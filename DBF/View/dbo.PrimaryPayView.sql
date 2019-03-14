USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE VIEW [dbo].[PrimaryPayView]
AS
	SELECT	PRP_ID_CLIENT, PRP_ID, DIS_STR, DIS_ID, PRP_DATE, PRP_PRICE, PRP_TAX_PRICE,
			PRP_TOTAL_PRICE, PRP_DOC, CD_ID_CLIENT,
			TX_ID, TX_PERCENT, TX_NAME, TX_CAPTION,
			DIS_ACTIVE, PRP_ID_INVOICE, PRP_COMMENT,
			PRP_ID_ORG
	FROM			
		dbo.PrimaryPayTable	
		LEFT OUTER JOIN dbo.ClientDistrView	ON DIS_ID = PRP_ID_DISTR 
		LEFT OUTER JOIN dbo.TaxTable ON PRP_ID_TAX = TX_ID
