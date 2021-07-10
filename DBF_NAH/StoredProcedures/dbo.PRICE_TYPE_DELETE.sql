USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  ������� ��� ������������ �
               ��������� ����� �� �����������
*/

ALTER PROCEDURE [dbo].[PRICE_TYPE_DELETE]
	@pricetypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.PriceTypeTable
	WHERE PT_ID = @pricetypeid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[PRICE_TYPE_DELETE] TO rl_price_type_d;
GO