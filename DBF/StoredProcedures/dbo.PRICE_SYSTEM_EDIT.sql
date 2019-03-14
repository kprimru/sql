USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  �������� ��������� ������� � 
               ������������
*/

CREATE PROCEDURE [dbo].[PRICE_SYSTEM_EDIT] 
	@pricesystemid INT,
	@price MONEY
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PriceSystemTable 
	SET PS_PRICE = @price    
	WHERE PS_ID = @pricesystemid

	SET NOCOUNT OFF
END