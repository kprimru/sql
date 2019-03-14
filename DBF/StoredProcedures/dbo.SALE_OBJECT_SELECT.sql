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

CREATE PROCEDURE [dbo].[SALE_OBJECT_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SO_ID, SO_NAME, TX_ID, TX_NAME
	FROM 
		dbo.SaleObjectTable a INNER JOIN
		dbo.TaxTable b ON a.SO_ID_TAX = b.TX_ID
	WHERE SO_ACTIVE = ISNULL(@active, SO_ACTIVE)
END

