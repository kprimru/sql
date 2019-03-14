USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Income].[INCOME_DETAIL_FULL_DATE]
	@ID_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID UNIQUEIDENTIFIER

	DECLARE @DEL_SUM MONEY
	DECLARE @SUP_SUM MONEY

	DECLARE @DEL_PAYED MONEY
	DECLARE @SUP_PAYED MONEY

	DECLARE @LAST_DATE SMALLDATETIME
	
	DECLARE @InTable TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO @InTable
		SELECT ID_ID
		FROM 
			Income.IncomeMasterGet(@ID_ID)
			


	DECLARE INC CURSOR LOCAL FOR 
		SELECT ID
		FROM @InTable
	OPEN INC

	FETCH NEXT FROM INC INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
			@DEL_SUM = ID_DEL_PRICE * ID_COUNT, 
			@SUP_SUM = ID_SUP_MONTH * ID_MON_CNT * ID_COUNT
		FROM Income.IncomeDetail
		WHERE ID_ID = @ID

		

		SELECT 
			@DEL_PAYED = SUM(ID_DEL_SUM), 
			@SUP_PAYED = SUM(ID_SUP_PRICE)
		FROM
			(
				SELECT 
					ID_DEL_SUM, ID_SUP_PRICE
				FROM
					Income.IncomeDetailFullView a INNER JOIN
					Income.Incomes y ON a.IN_ID = y.IN_ID
				WHERE NOT EXISTS
					(
						SELECT *
						FROM 
							Income.IncomeDetail b INNER JOIN
							Income.Incomes c ON b.ID_ID_INCOME = c.IN_ID
						WHERE a.IN_ID = c.IN_ID_INCOME
					) AND ID_ID = @ID AND y.IN_ID_INCOME IS NULL

				UNION

				SELECT 		
					(
						SELECT SUM(h.ID_DEL_SUM)	
						FROM 
							Income.Incomes g INNER JOIN
							Income.IncomeDetailFullVIew h ON g.IN_ID = h.IN_ID
									AND h.SYS_ID_MASTER = d.SYS_ID_MASTER
									AND h.DT_ID_MASTER = d.DT_ID_MASTER
									AND h.NT_ID_MASTER = d.NT_ID_MASTER
									AND h.TT_ID_MASTER = d.TT_ID_MASTER
						WHERE d.IN_ID = g.IN_ID_INCOME OR d.IN_ID = g.IN_ID
					) AS ID_DEL_SUM, 
					(
						SELECT SUM(h.ID_SUP_PRICE)	
					FROM 
						Income.Incomes g INNER JOIN
						Income.IncomeDetailFullVIew h ON g.IN_ID = h.IN_ID
									AND h.SYS_ID_MASTER = d.SYS_ID_MASTER
									AND h.DT_ID_MASTER = d.DT_ID_MASTER
									AND h.NT_ID_MASTER = d.NT_ID_MASTER
									AND h.TT_ID_MASTER = d.TT_ID_MASTER
						WHERE d.IN_ID = g.IN_ID_INCOME OR d.IN_ID = g.IN_ID
					) AS ID_SUP_PRICE
				FROM
					Income.IncomeDetailFullView d INNER JOIN
					Income.Incomes z ON z.IN_ID = d.IN_ID
				WHERE EXISTS
					(
						SELECT *
						FROM 
							Income.IncomeDetail e INNER JOIN
							Income.Incomes f ON e.ID_ID_INCOME = f.IN_ID
						WHERE d.IN_ID = f.IN_ID_INCOME
					) AND d.ID_ID = @ID --AND z.IN_ID_INCOME IS NULL
			) AS o_O

		

		IF (@DEL_PAYED = @DEL_SUM) AND (@SUP_PAYED = @SUP_SUM)
		BEGIN
			SELECT @LAST_DATE = MAX(IN_DATE)
			FROM
				(
					SELECT 
						IN_DATE
					FROM
						Income.IncomeFullView a 
					WHERE ID_ID IN
						(
							SELECT ID_ID
							FROM Income.IncomeDetailAllGet(@ID)
						)
				) AS o_O
		END
		ELSE
		BEGIN
			SET @LAST_DATE = NULL
		END

		UPDATE	Income.IncomeDetail
		SET		ID_FULL_DATE = @LAST_DATE
		WHERE	ID_ID IN
			(
				SELECT ID_ID 
				FROM Income.IncomeDetailAllGet(@ID)
			) 		

		FETCH NEXT FROM INC INTO @ID
	END

	CLOSE INC
	DEALLOCATE INC
			

	IF EXISTS
		(
			SELECT *
			FROM Income.IncomeDetail
			WHERE ID_ID IN
				(
					SELECT ID
					FROM @InTable
				)
				AND ID_FULL_DATE IS NULL
		)	
	BEGIN
		UPDATE Income.IncomeDetail
		SET ID_FULL_DATE = NULL
		WHERE ID_ID IN
			(
				SELECT ID
				FROM @InTable

				UNION ALL

				SELECT ID_ID
				FROM Income.IncomeAllGet(@ID_ID)
			)
	END
END
