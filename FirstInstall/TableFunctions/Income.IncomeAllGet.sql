USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE FUNCTION [Income].[IncomeAllGet]
(	
	@ID_ID	UNIQUEIDENTIFIER
)
RETURNS 
@TBL TABLE 
(
	ID_ID UNIQUEIDENTIFIER
)
AS
BEGIN
	INSERT INTO @TBL
		/*
			Выбирает все Detail-записи платежа, 
			в который входит текущая запись
		*/
		SELECT ID_ID
		FROM 
			Income.IncomeDetail a INNER JOIN
			Income.Incomes b ON a.ID_ID_INCOME = b.IN_ID
		WHERE IN_ID = 
			(
				SELECT ID_ID_INCOME
				FROM Income.IncomeDetail
				WHERE ID_ID = @ID_ID
			)

		UNION	

		/*
			Выбирает все доплаты по текущей записи
		*/
		SELECT d.ID_ID
		FROM 
			Income.IncomeDetail a INNER JOIN
			Income.Incomes b ON a.ID_ID_INCOME = b.IN_ID INNER JOIN
			Income.Incomes c ON b.IN_ID = c.IN_ID_INCOME INNER JOIN
			Income.IncomeDetail d ON d.ID_ID_INCOME = c.IN_ID
		WHERE b.IN_ID IN
			(
				SELECT ID_ID_INCOME
				FROM Income.IncomeDetail
				WHERE ID_ID = @ID_ID
			)

		UNION	

		/*
			Выбирает все основные части для подчиненных
		*/
		SELECT d.ID_ID
		FROM 
			Income.IncomeDetail a INNER JOIN
			Income.Incomes b ON a.ID_ID_INCOME = b.IN_ID INNER JOIN
			Income.Incomes c ON c.IN_ID = b.IN_ID_INCOME INNER JOIN
			Income.IncomeDetail d ON d.ID_ID_INCOME = c.IN_ID
		WHERE b.IN_ID IN
			(
				SELECT ID_ID_INCOME
				FROM Income.IncomeDetail
				WHERE ID_ID = @ID_ID
			)

		
	
	RETURN 
END
