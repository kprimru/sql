USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  ���������� ID ���� ������������
               � ��������� ���������.
*/

ALTER PROCEDURE [dbo].[PRICE_GROUP_CHECK_NAME]
	@name VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	SELECT PG_ID
	FROM dbo.PriceGroupTable
	WHERE PG_NAME = @name

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[PRICE_GROUP_CHECK_NAME] TO rl_price_group_w;
GO