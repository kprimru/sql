USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ServiceStateTypeView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ServiceStateTypeView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ServiceStateTypeView]
AS
	SELECT 'COMPLIANCE' AS TP_NAME, '�� ������������� ������� (��������)' AS TP_NOTE, 1 AS TP_ORD
				UNION ALL
				SELECT 'RES' AS TP_NAME, '������ ���������������� ������ / cons.exe (��������)' AS TP_NOTE, 2 AS TP_ORD
				UNION ALL
				SELECT 'STT' AS TP_NAME, '���� ������ STT (���������)' AS TP_NOTE, 3 AS TP_ORD
				UNION ALL
				SELECT 'CFG' AS TP_NAME, '���� ������ ������� ������� (��������)' AS TP_NOTE, 4 AS TP_ORD
				UNION ALL
				SELECT 'PAY' AS TP_NAME, '�������� (��������)' AS TP_NOTE, 5 AS TP_ORD
				UNION ALL
				SELECT 'IB' AS TP_NAME, '��������������� �� (��������)' AS TP_NOTE, 6 AS TP_ORD
				UNION ALL
				SELECT 'UPDATE' AS TP_NAME, '����� �� ����������� (��������)' AS TP_NOTE, 7 AS TP_ORD
				UNION ALL
				SELECT 'SEMINAR' AS TP_NAME, '�� ������������ �� �������' AS TP_NOTE, 8 AS TP_ORD
				UNION ALL
				SELECT 'INNOVATION' AS TP_NAME, '�����������' AS TP_NOTE, 9 AS TP_ORD
				UNION ALL
				SELECT 'GRAPH' AS TP_NAME, '������ ��' AS TP_NOTE, 10 AS TP_ORD
GO
