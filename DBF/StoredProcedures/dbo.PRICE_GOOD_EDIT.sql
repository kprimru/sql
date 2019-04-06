USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 20.11.2008
Описание:	  Изменить данные о типе прейскуранта
               с указанным кодом
*/

CREATE PROCEDURE [dbo].[PRICE_GOOD_EDIT] 
	@id SMALLINT,
	@name VARCHAR(50),	
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PriceGoodTable 
	SET PGD_NAME = @name,
		PGD_ACTIVE = @active
	WHERE PGD_ID = @id

	SET NOCOUNT OFF
END
