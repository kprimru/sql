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

CREATE PROCEDURE [dbo].[PRICE_GOOD_CHECK_NAME] 
	@name VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	SELECT PGD_ID
	FROM dbo.PriceGoodTable
	WHERE PGD_NAME = @name

	SET NOCOUNT OFF
END
