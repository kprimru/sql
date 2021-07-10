USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  �������� ��� ������������ �
               ����������
*/

ALTER PROCEDURE [dbo].[PRICE_GOOD_ADD]
	@name VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.PriceGoodTable(PGD_NAME, PGD_ACTIVE)
	VALUES (@name, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[PRICE_GOOD_ADD] TO rl_price_good_w;
GO