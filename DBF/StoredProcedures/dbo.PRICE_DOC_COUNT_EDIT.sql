USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Изменить данные о количестве 
               документов для указанной системы 
               на указанную дату
*/

CREATE PROCEDURE [dbo].[PRICE_DOC_COUNT_EDIT] 
	@systemid SMALLINT,
	@periodid SMALLINT,
	@doccount INT
AS
BEGIN
	SET NOCOUNT ON

	IF EXISTS (
				SELECT * 
				FROM dbo.PriceSystemHistoryTable 
				WHERE PSH_ID_SYSTEM = @systemid AND 
					PSH_ID_PERIOD = @periodid
				)
	BEGIN
		UPDATE dbo.PriceSystemHistoryTable
		SET PSH_DOC_COUNT = @doccount           
		WHERE PSH_ID_SYSTEM = @systemid AND 
			PSH_ID_PERIOD = @periodid
	END
	ELSE
    BEGIN
		INSERT INTO dbo.PriceSystemHistoryTable (PSH_ID_PERIOD, PSH_ID_SYSTEM, PSH_DOC_COUNT)
		VALUES (@periodid, @systemid, @doccount)
	END

	SET NOCOUNT OFF
END