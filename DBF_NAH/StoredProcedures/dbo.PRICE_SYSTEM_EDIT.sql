USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[PRICE_SYSTEM_EDIT]
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
GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_EDIT] TO rl_price_list_w;
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_EDIT] TO rl_price_val_w;
GO