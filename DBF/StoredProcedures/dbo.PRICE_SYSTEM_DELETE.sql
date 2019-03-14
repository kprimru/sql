USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  ������� ������� �� ������������
*/

CREATE PROCEDURE [dbo].[PRICE_SYSTEM_DELETE] 
	@pricesystemid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PriceSystemTable 
	WHERE PS_ID = @pricesystemid

	SET NOCOUNT OFF
END



