USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[PRICE_GOOD_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PGD_ID, PGD_NAME
	FROM 		
		dbo.PriceGoodTable 
	WHERE PGD_ACTIVE = ISNULL(@active, PGD_ACTIVE)
	ORDER BY PGD_NAME

	SET NOCOUNT OFF
END
