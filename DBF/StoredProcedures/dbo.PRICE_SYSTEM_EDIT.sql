USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Изменить стоимость системы в 
               прейскуранте
*/

CREATE PROCEDURE [dbo].[PRICE_SYSTEM_EDIT] 
	@pricesystemid INT,
	@price MONEY
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PriceSystemTable 
	SET PS_PRICE = @price    
	WHERE PS_ID = @pricesystemid

	SET NOCOUNT OFF
END