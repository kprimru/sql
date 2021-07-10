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

ALTER PROCEDURE [dbo].[PRICE_GROUP_DELETE]
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.PriceGroupTable
	WHERE PG_ID = @id

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[PRICE_GROUP_DELETE] TO rl_price_group_d;
GO