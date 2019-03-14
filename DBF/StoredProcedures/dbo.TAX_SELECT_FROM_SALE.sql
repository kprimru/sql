USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[TAX_SELECT_FROM_SALE]
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TX_PERCENT
	FROM 
		dbo.TaxTable INNER JOIN
		dbo.SaleObjectTable ON SO_ID_TAX = TX_ID
	WHERE SO_ID = @soid
END
