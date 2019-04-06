USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Удалить тип прейскуранта с 
               указанным кодом из справочника
*/

CREATE PROCEDURE [dbo].[PRICE_DELETE] 
	@priceid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PriceTable 
	WHERE PP_ID = @priceid

	SET NOCOUNT OFF
END