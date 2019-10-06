USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
�����:			������� �������/������ ��������
���� ��������:	24.03.2009
��������:		������ ������� �����-�������
*/

CREATE PROCEDURE [dbo].[CLIENT_INVOICE_ROW_SELECT]
	@invid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		INR_ID, DIS_ID, DIS_STR, INR_GOOD, INR_NAME, PR_ID, PR_NAME, INR_SUM, INR_ID_TAX, TX_NAME, TX_CAPTION,
		INR_TNDS, INR_SNDS, INR_SALL, INR_UNIT, INR_COUNT
		
	FROM 
		dbo.InvoiceRowTable A
		LEFT OUTER JOIN dbo.TaxTable B ON A.INR_ID_TAX = B.TX_ID 
		LEFT OUTER JOIN dbo.PeriodTable C ON A.INR_ID_PERIOD = C.PR_ID 
		LEFT OUTER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = INR_ID_DISTR
	WHERE INR_ID_INVOICE = @invid
END