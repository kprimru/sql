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

ALTER PROCEDURE [dbo].[SALE_OBJECT_DELETE]
	@soid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.SaleObjectTable
	WHERE SO_ID = @soid
END


GO
GRANT EXECUTE ON [dbo].[SALE_OBJECT_DELETE] TO rl_sale_object_d;
GO