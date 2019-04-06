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

CREATE PROCEDURE [dbo].[MARKET_AREA_GET] 
	@marketareaid INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT MA_ID, MA_NAME, MA_SHORT_NAME, MA_ACTIVE
	FROM dbo.MarketAreaTable 
	WHERE MA_ID = @marketareaid 

	SET NOCOUNT OFF
END




