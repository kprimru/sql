USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 05.11.2008
Описание:	  Удалить из справочника сбытовую 
               территорию с указанным кодом
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_DELETE] 
	@marketareaid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.MarketAreaTable 
	WHERE MA_ID = @marketareaid

	SET NOCOUNT OFF
END