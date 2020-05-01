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

ALTER FUNCTION [dbo].[PERIOD_PREV]
(
	-- ������ ���������� �������
	@prid SMALLINT
)
-- ���, ������� ����������
RETURNS SMALLINT
AS
BEGIN
	-- ���������� � ������� ����� ��������� ��������� ������ �������
	DECLARE @result SMALLINT

	-- ���� �������
	SELECT @result = PR_ID 
	FROM dbo.PeriodTable
	WHERE PR_DATE = 
			(
				SELECT DATEADD(MONTH, -1, PR_DATE)
				FROM dbo.PeriodTable 
				WHERE PR_ID = @prid
			)


	-- ����������� ���������� ������ �������
	RETURN @result

END
