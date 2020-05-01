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

ALTER FUNCTION [dbo].[GET_SETTING]
(
	-- ������ ���������� �������
	@sname VARCHAR(500)
)
-- ���, ������� ����������
RETURNS VARCHAR(500)
AS
BEGIN
	-- ���������� � ������� ����� ��������� ��������� ������ �������
	DECLARE @result VARCHAR(500)

	-- ���� �������
	SELECT @result = GS_VALUE
	FROM dbo.GlobalSettingsTable
	WHERE GS_NAME = @sname

	-- ����������� ���������� ������ �������
	RETURN @result

END
