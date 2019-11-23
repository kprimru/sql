USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[REG_PROTOCOL_OPERS]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT RPR_OPER
	FROM dbo.RegProtocol
	WHERE RPR_OPER NOT LIKE '"%'
		AND RPR_OPER NOT LIKE '�������� � ��������%'
		AND RPR_OPER NOT LIKE '������� email%'
		AND RPR_OPER NOT LIKE '������� �������%'
		AND RPR_OPER NOT LIKE '������� ������������� �������%'
		AND RPR_OPER NOT LIKE '������� �����������%'
		AND RPR_OPER NOT LIKE '������� ���. ��������%'
		AND RPR_OPER NOT LIKE '������� ����� ��������%'
		AND RPR_OPER NOT LIKE '������� ����. ���%'
		AND RPR_OPER NOT LIKE '�������� ����%'
		AND RPR_OPER NOT LIKE '������� ��%'
		AND RPR_OPER NOT LIKE '�������� �����%'
		AND RPR_OPER NOT LIKE '�������� �����������%'
		AND RPR_OPER NOT LIKE '�������� �����������%'
		AND RPR_OPER NOT LIKE '������� Yubikey%'
		AND RPR_OPER NOT LIKE '�������� Yubikey%'
		AND RPR_OPER NOT LIKE '�������� Yubikey%'
		AND RPR_OPER NOT LIKE '������ ����������� �������%'
		AND RPR_OPER NOT LIKE '�������� ����%'
		AND RPR_OPER NOT LIKE '����������� ���������� ���������� ��������%'
		AND RPR_OPER NOT LIKE '������� ������ ��%'
		AND RPR_OPER NOT LIKE '����������� ��������� ��%'
		AND RPR_OPER NOT LIKE '�������%'
	ORDER BY RPR_OPER
END
