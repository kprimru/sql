USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
�����:			������� �������/������ ��������
���� ��������:  24.03.2009
��������:		��� �����-������� �������
*/

CREATE PROCEDURE [dbo].[SINGLE_INVOICE_SELECT]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	INS_ID, 
			INS_DATE, (CONVERT(varchar,INS_NUM)+'/'+INS_NUM_YEAR) AS INS_FULL_NUM,
			ORG_PSEDO,
			IF_TOTAL_PRICE, -- INS_STORNO, INS_COMMENT,
			INT_NAME
	FROM dbo.InvoiceView
	WHERE INS_ID_CLIENT IS NULL
	ORDER BY INS_DATE DESC, INS_NUM

END
















