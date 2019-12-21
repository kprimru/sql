USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/
CREATE PROCEDURE [dbo].[CLIENT_ACT_SELECT]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ACT_ID, ACT_DATE, ACT_PRICE, 
		(CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_NUM, 
		ACT_PRINT, ACT_SIGN, ORG_PSEDO,
		COUR_ID, COUR_NAME, ISNULL(CL_PSEDO, '') AS PAYER,
		SO_CODE = (
			-- ToDo ��� �����, ����� �������� �� ����� ����� �������� ���.
			-- � ��������, ����, ������� ���������� �� ������ ������ ������ ���� ������ ������ � ����
			SELECT TOP (1) SO_CODE
			FROM dbo.ActDistrTable
			INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR
			INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
			WHERE AD_ID_ACT = ACT_ID
			ORDER BY SO_ID
		)
	FROM dbo.ActView
	LEFT JOIN dbo.InvoiceSaleTable	ON INS_ID = ACT_ID_INVOICE
	LEFT JOIN dbo.ClientTable		ON ACT_ID_PAYER = CL_ID
	WHERE ACT_ID_CLIENT = @clientid
	ORDER BY ACT_DATE DESC
END