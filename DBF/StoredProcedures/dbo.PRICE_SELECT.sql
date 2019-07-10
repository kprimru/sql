USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[PRICE_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PP_ID, PP_NAME, PT_NAME, PP_COEF_MUL, PP_COEF_ADD
	FROM 
		dbo.PriceTable a INNER JOIN
		dbo.PriceTypeTable b ON a.PP_ID_TYPE = b.PT_ID
	WHERE PP_ACTIVE = ISNULL(@active, PP_ACTIVE)
	ORDER BY PP_NAME

	SET NOCOUNT OFF
END








