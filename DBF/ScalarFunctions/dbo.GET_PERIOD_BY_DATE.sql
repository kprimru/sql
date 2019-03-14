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

CREATE FUNCTION [dbo].[GET_PERIOD_BY_DATE]
(
	-- ������ ���������� �������
	@date SMALLDATETIME
)
-- ���, ������� ����������
RETURNS INT
AS
BEGIN
	-- ���������� � ������� ����� ��������� ��������� ������ �������
	DECLARE @result INT

	-- ���� �������
	SELECT @result = PR_ID
	FROM dbo.PeriodTable
	WHERE PR_DATE <= @date AND @date <= PR_END_DATE


	-- ����������� ���������� ������ �������
	RETURN @result

END
