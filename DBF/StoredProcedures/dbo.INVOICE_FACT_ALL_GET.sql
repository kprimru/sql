USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[INVOICE_FACT_ALL_GET]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IFM_DATE, COUNT(*) AS IFM_COUNT
	FROM dbo.InvoiceFactMasterTable
	GROUP BY IFM_DATE
	ORDER BY IFM_DATE DESC
END



