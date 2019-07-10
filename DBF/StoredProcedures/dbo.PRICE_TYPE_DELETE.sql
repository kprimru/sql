USE [DBF]
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

CREATE PROCEDURE [dbo].[PRICE_TYPE_DELETE] 
	@pricetypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PriceTypeTable 
	WHERE PT_ID = @pricetypeid

	SET NOCOUNT OFF
END