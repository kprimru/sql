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

CREATE PROCEDURE [dbo].[PRICE_GROUP_GET] 
	@id SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT PG_ID, PG_NAME, PG_ACTIVE
	FROM 		
		dbo.PriceGroupTable
	WHERE PG_ID = @id 

	SET NOCOUNT OFF
END
