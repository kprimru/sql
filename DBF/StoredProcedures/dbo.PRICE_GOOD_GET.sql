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

CREATE PROCEDURE [dbo].[PRICE_GOOD_GET] 
	@id SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PGD_ID, PGD_NAME, PGD_ACTIVE
	FROM 		
		dbo.PriceGoodTable
	WHERE PGD_ID = @id 

	SET NOCOUNT OFF
END
