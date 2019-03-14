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

CREATE PROCEDURE [dbo].[BILL_REST_GET]
	-- Список параметров процедуры
	@clientid INT,
	@periodid SMALLINT
AS
BEGIN
	-- SET NOCOUNT ON обязателен для использования в хранимых процедурах.
	-- Позволяет избежать лишней информации и сетевого траффика.

	SET NOCOUNT ON;

	-- Текст процедуры ниже
	SELECT 
		BD_ID, DIS_ID, DIS_STR, BD_TOTAL_PRICE, 
			(
				SELECT SUM(ID_PRICE)
				FROM 
					dbo.IncomeDistrTable INNER JOIN
					dbo.IncomeTable ON ID_ID_INCOME = IN_ID INNER JOIN
					dbo.DistrView ON DIS_ID = ID_ID_DISTR INNER JOIN
					dbo.SaleObjectTable b ON SO_ID = SYS_ID_SO
				WHERE ID_ID_DISTR = DIS_ID 
					AND ID_ID_PERIOD = PR_ID
					AND IN_ID_CLIENT = BL_ID_CLIENT
					AND b.SO_ID = a.SO_ID
			) AS BD_PAY,
		BD_TOTAL_PRICE -
			ISNULL((
				SELECT SUM(ID_PRICE)
				FROM 
					dbo.IncomeDistrTable INNER JOIN
					dbo.IncomeTable ON ID_ID_INCOME = IN_ID INNER JOIN
					dbo.DistrView ON DIS_ID = ID_ID_DISTR INNER JOIN
					dbo.SaleObjectTable b ON SO_ID = SYS_ID_SO
				WHERE ID_ID_DISTR = DIS_ID 
					AND ID_ID_PERIOD = PR_ID
					AND IN_ID_CLIENT = BL_ID_CLIENT
					AND b.SO_ID = a.SO_ID
			), 0) AS BD_UNPAY 
	FROM 
		dbo.BillDistrView a 
	WHERE PR_ID = @periodid AND BL_ID_CLIENT = @clientid
	ORDER BY DIS_STR
END




