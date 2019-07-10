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

CREATE PROCEDURE [dbo].[BILL_DISTR_EDIT]
	-- ������ ���������� ���������
	@bdid INT,
	@price MONEY,
	@taxprice MONEY,
	@totalprice MONEY
AS
BEGIN
	-- SET NOCOUNT ON ���������� ��� ������������� � �������� ����������.
	-- ��������� �������� ������ ���������� � �������� ��������.

	SET NOCOUNT ON;

	-- ����� ��������� ����
	UPDATE dbo.BillDIstrTable
	SET BD_PRICE = @price,
		BD_TAX_PRICE = @taxprice,
		BD_TOTAL_PRICE = @totalprice
	WHERE BD_ID = @bdid
END




