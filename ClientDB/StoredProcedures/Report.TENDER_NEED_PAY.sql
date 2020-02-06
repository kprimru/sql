USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[TENDER_NEED_PAY]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SELECT 
		t.CLIENT AS [������������ ���������],
		SHORT AS [�����/�-����],
		p.CLAIM_PRIVISION AS [����� ����������� ������],
		CASE DATEPART(dw, p.DATE)
			WHEN 1 THEN p.DATE+2
			WHEN 2 THEN p.DATE+1
			WHEN 3 THEN p.DATE+2
			WHEN 4 THEN p.DATE+1
			WHEN 5 THEN p.DATE+5
			WHEN 6 THEN p.DATE+4
			WHEN 7 THEN p.DATE+3
		END AS [���� ������],
		TS_SHORT AS [��. ��.],
		GK_SUM AS [����],
		NOTICE_NUM AS [����� ���������],
		DATE AS [���� ���������]
	FROM 
		Tender.Tender t
		INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
		INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
		INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
	WHERE ID_STATUS = (
					SELECT ID
					FROM Tender.Status
					WHERE PSEDO = 'TENDER'
						)
	

	UNION ALL

	SELECT
		'����� : ', '', SUM(p.CLAIM_PRIVISION), NULL, NULL, NULL, NULL, NULL
	FROM 
		Tender.Tender t
		INNER JOIN Tender.Placement p ON t.ID = p.ID_TENDER
		INNER JOIN dbo.Vendor v ON p.ID_VENDOR = v.ID
		INNER JOIN Purchase.TradeSite TS on p.ID_TRADESITE = ts.TS_ID
	WHERE ID_STATUS = (
					SELECT ID
					FROM Tender.Status
					WHERE PSEDO = 'TENDER'
						)
	ORDER BY DATE DESC

END
