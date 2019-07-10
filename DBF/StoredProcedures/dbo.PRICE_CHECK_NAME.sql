USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Возвращает ID прейскуранта 
               с указанным названием. 
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