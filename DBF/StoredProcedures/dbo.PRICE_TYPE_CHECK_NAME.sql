USE [DBF]
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

CREATE PROCEDURE [dbo].[PRICE_TYPE_CHECK_NAME] 
	@pricetypename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT PT_ID
	FROM dbo.PriceTypeTable
	WHERE PT_NAME = @pricetypename

	SET NOCOUNT OFF
END