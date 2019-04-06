USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[CLAIM_SELECT]
	@TENDER	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ID, TP,
		CASE TP 
			WHEN 1 THEN '����������� ������' 
			WHEN 2 THEN '����������� ���������' 
			WHEN 3 THEN '������ �� �������'
			WHEN 4 THEN '������ �� �����'
			WHEN 5 THEN '������ �� ���'
			WHEN 6 THEN '������ �� ���'
			ELSE '�������� ��������' 
		END AS TP_STR, 
		CLAIM_DATE
	FROM Tender.Claim
	WHERE ID_TENDER = @TENDER
	ORDER BY CLAIM_DATE DESC
END
