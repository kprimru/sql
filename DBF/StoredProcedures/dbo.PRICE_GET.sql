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

CREATE PROCEDURE [dbo].[PRICE_GET] 
	@priceid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PP_ID, PP_NAME, PT_NAME, PT_ID, PP_COEF_MUL, PP_COEF_ADD, PP_ACTIVE
	FROM 
		dbo.PriceTable a INNER JOIN
		dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID
	WHERE PP_ID = @priceid 

	SET NOCOUNT OFF
END








