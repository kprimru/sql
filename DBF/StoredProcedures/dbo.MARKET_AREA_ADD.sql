USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 05.11.2008
Описание:	  Добавить тип сбытовой территории
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_ADD] 
	@marketareaname VARCHAR(150),
	@marketareashortname VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.MarketAreaTable(MA_NAME, MA_SHORT_NAME, MA_ACTIVE) 
	VALUES (@marketareaname, @marketareashortname, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END