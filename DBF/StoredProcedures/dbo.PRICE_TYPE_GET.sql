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

CREATE PROCEDURE [dbo].[PRICE_TYPE_GET] 
	@pricetypeid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PT_ID, PT_NAME, PG_ID, PG_NAME, PT_COEF, PT_ORDER, PT_ACTIVE
	FROM 
		dbo.PriceTypeTable LEFT OUTER JOIN
		dbo.PriceGroupTable ON PG_ID = PT_ID_GROUP
	WHERE PT_ID = @pricetypeid 

	SET NOCOUNT OFF
END
