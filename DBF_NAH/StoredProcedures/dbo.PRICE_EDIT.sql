USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  �������� ������ � ������������
                � ��������� �����
*/

ALTER PROCEDURE [dbo].[PRICE_EDIT]
	@priceid SMALLINT,
	@pricename VARCHAR(50),
	@pricetypeid SMALLINT,
	@pricecoefmul NUMERIC(8, 4),
	@pricecoefadd MONEY,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PriceTable
	SET PP_NAME = @pricename,
		PP_ID_TYPE = @pricetypeid,
		PP_COEF_MUL = @pricecoefmul,
		PP_COEF_ADD = @pricecoefadd,
		PP_ACTIVE = @active
	WHERE PP_ID = @priceid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[PRICE_EDIT] TO rl_price_w;
GO