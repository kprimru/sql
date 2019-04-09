USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientTrustView]
WITH SCHEMABINDING
AS
	SELECT 
		CT_ID, CC_ID_CLIENT, CT_ID_CALL, CC_DATE, CC_USER,
		CT_MAKE_USER + ' ' + CONVERT(VARCHAR(20), CT_MAKE, 104) + ' ' + CONVERT(VARCHAR(20), CT_MAKE, 108) AS CT_MAKE_DATA,
		CT_NOTE, CT_TRUST, CT_MAKE,
		CASE
			WHEN CT_TRUST = 1 THEN '����������'
			WHEN CT_TRUST = 0 AND CT_MAKE IS NULL THEN '�� ����������'
			WHEN CT_TRUST = 0 AND CT_MAKE IS NOT NULL THEN '�� ���������� (���������)'
			ELSE '����������'
		END AS CT_TRUST_STR,
		CASE
			WHEN CT_TRUST = 1 THEN 1
			WHEN CT_TRUST = 0 AND CT_MAKE IS NULL THEN 0
			WHEN CT_TRUST = 0 AND CT_MAKE IS NOT NULL THEN 2
			ELSE -1
		END AS CT_TRUST_STATUS,		
		CASE CT_TNAME
			WHEN 1 THEN '��������: ' + CT_NAME + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TADDRESS
			WHEN 1 THEN '�����: ' + CT_ADDRESS + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TDIR
			WHEN 1 THEN '��� ������������: ' + CT_DIR + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TDIR_POS
			WHEN 1 THEN '��������� ������������: ' + CT_DIR_POS + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TDIR_PHONE
			WHEN 1 THEN '���. ������������: ' + CT_DIR_PHONE + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TBUH
			WHEN 1 THEN '��� ��.���.: ' + CT_BUH + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TBUH_POS
			WHEN 1 THEN '��������� ��.���.: ' + CT_BUH_POS + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TBUH_PHONE
			WHEN 1 THEN '���. ��.���: ' + CT_BUH_PHONE + CHAR(10)
			ELSE ''
		END +
		CASE CT_TRES
			WHEN 1 THEN '��� ��������.: ' + CT_RES + CHAR(10)
			ELSE ''
		END +
		CASE CT_TRES_POS
			WHEN 1 THEN '��������� ��������.: ' + CT_RES_POS + CHAR(10)
			ELSE ''
		END + 
		CASE CT_TRES_PHONE
			WHEN 1 THEN '������� ��������.: ' + CT_RES_PHONE + CHAR(10)
			ELSE ''
		END AS CT_CORRECT
	FROM 
		dbo.ClientTrust
		INNER JOIN dbo.ClientCall ON CC_ID = CT_ID_CALL
