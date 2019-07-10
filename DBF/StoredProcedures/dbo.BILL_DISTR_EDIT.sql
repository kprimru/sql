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

CREATE PROCEDURE [dbo].[BILL_DISTR_EDIT]
	-- Список параметров процедуры
	@bdid INT,
	@price MONEY,
	@taxprice MONEY,
	@totalprice MONEY
AS
BEGIN
	-- SET NOCOUNT ON обязателен для использования в хранимых процедурах.
	-- Позволяет избежать лишней информации и сетевого траффика.

	SET NOCOUNT ON;

	-- Текст процедуры ниже
	UPDATE dbo.BillDIstrTable
	SET BD_PRICE = @price,
		BD_TAX_PRICE = @taxprice,
		BD_TOTAL_PRICE = @totalprice
	WHERE BD_ID = @bdid
END




