USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[SALE_OBJECT_GET]
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SO_NAME, TX_ID, TX_NAME, /*SO_INV_UNIT, SO_OKEI, */SO_ACTIVE, SO_CODE
	FROM
		dbo.SaleObjectTable a INNER JOIN
		dbo.TaxTable b ON a.SO_ID_TAX = b.TX_ID
	WHERE SO_ID = @soid
END
GO
GRANT EXECUTE ON [dbo].[SALE_OBJECT_GET] TO rl_sale_object_r;
GO