USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Удалить систему из прейскуранта
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



