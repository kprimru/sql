USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 05.11.2008
Описание:	  Изменить данные о сбытовой 
               территории с указанным кодом
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_EDIT] 
	@marketareaid INT,
	@marketareaname VARCHAR(100),
	@marketareashortname VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.MarketAreaTable 
	SET MA_NAME = @marketareaname, 
		MA_SHORT_NAME = @marketareashortname,
		MA_ACTIVE = @active
	WHERE MA_ID = @marketareaid

	SET NOCOUNT OFF
END