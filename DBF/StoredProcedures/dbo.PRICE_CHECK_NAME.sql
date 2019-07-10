USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  ���������� ID ������������ 
               � ��������� ���������. 
*/

CREATE PROCEDURE [dbo].[PRICE_CHECK_NAME] 
	@pricename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT PP_ID
	FROM dbo.PriceTable
	WHERE PP_NAME = @pricename

	SET NOCOUNT OFF
END