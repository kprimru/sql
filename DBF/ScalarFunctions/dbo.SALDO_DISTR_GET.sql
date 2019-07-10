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

CREATE FUNCTION [dbo].[SALDO_DISTR_GET]
(
	-- ������ ���������� �������
	@clientid INT,
	@distrid INT
)
-- ���, ������� ����������
RETURNS MONEY
AS
BEGIN
	-- ���������� � ������� ����� ��������� ��������� ������ �������
	DECLARE @result MONEY

	-- ���� �������
	
	SELECT TOP 1 @result = SL_REST
	FROM dbo.SaldoTable
	WHERE SL_ID_DISTR = @distrid 
		AND SL_ID_CLIENT = @clientid
	ORDER BY SL_DATE DESC, SL_ID DESC

	-- ����������� ���������� ������ �������
	RETURN @result

END

