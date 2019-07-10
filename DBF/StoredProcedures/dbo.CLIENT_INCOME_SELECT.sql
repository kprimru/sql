USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			������� �������/������ ��������
��������:		
*/
CREATE PROCEDURE [dbo].[CLIENT_INCOME_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		IN_ID, IN_DATE, IN_SUM, IN_PAY_DATE, IN_PAY_NUM, IN_REST, IN_PRIMARY, (CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_NUM,
		ORG_PSEDO
	FROM 
		dbo.IncomeView LEFT OUTER JOIN
		dbo.InvoiceSaleTable ON INS_ID = IN_ID_INVOICE
	WHERE IN_ID_CLIENT = @clientid
	ORDER BY IN_DATE DESC
END