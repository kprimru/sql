USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

CREATE FUNCTION [Salary].[SalaryFromIncome]
(
	@ID_ID	UNIQUEIDENTIFIER
)
RETURNS MONEY
AS
BEGIN	
	DECLARE @RESULT MONEY

	DECLARE @ID_COUNT TINYINT
	DECLARE @ID_DEL_SUM MONEY
	DECLARE @ID_DEL_DISCOUNT DECIMAL(8, 4)
	DECLARE @ID_ACTION BIT
	DECLARE @ID_RESTORE BIT
	DECLARE @ID_MON_CNT TINYINT
	DECLARE @ID_SUP_PRICE MONEY
	DECLARE @ID_SUP_DISCOUNT DECIMAL(8, 4)
	DECLARE @ID_PREPAY BIT
	DECLARE @ID_SUP_CONTRACT SMALLDATETIME
	DECLARE @ID_SUP_DATE SMALLDATETIME
	DECLARE @SYS_MAIN BIT
	DECLARE @DT_ID_MASTER UNIQUEIDENTIFIER
	DECLARE @ID_SUP_MONTH MONEY

	SELECT 		
		@ID_COUNT = ID_COUNT, 
		@ID_DEL_SUM = ID_DEL_SUM_NDS, 
		@ID_DEL_DISCOUNT = ID_DEL_DISCOUNT,
		@ID_ACTION = ID_ACTION,
		@ID_RESTORE = ID_RESTORE,
		@ID_MON_CNT = ID_MON_CNT,
		@ID_SUP_PRICE = ID_SUP_PRICE_NDS,
		@ID_SUP_DISCOUNT = ID_SUP_DISCOUNT,
		@ID_PREPAY = ID_PREPAY,
		@ID_SUP_CONTRACT = ID_SUP_CONTRACT,
		@ID_SUP_DATE = ID_SUP_DATE,
		@SYS_MAIN = SYS_MAIN,
		@DT_ID_MASTER = DT_ID_MASTER,
		@ID_SUP_MONTH = ID_SUP_MONTH		
	FROM 
		(
			SELECT 
				ID_COUNT, ID_DEL_SUM_NDS, ID_DEL_DISCOUNT,
				ID_ACTION, ID_RESTORE, ID_MON_CNT,
				ID_SUP_PRICE_NDS, ID_SUP_DISCOUNT, ID_PREPAY,
				ID_SUP_CONTRACT, ID_SUP_DATE, SYS_MAIN,
				DT_ID_MASTER, ID_SUP_MONTH
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
				) AND ID_ID = @ID_ID AND y.IN_ID_INCOME IS NULL

			UNION

			SELECT 
				ID_COUNT, 
				(
					SELECT SUM(h.ID_DEL_SUM_NDS)	
					FROM 
						Income.Incomes g INNER JOIN
						Income.IncomeDetailFullVIew h ON g.IN_ID = h.IN_ID
								AND h.SYS_ID_MASTER = d.SYS_ID_MASTER
								AND h.DT_ID_MASTER = d.DT_ID_MASTER
								AND h.NT_ID_MASTER = d.NT_ID_MASTER
								AND h.TT_ID_MASTER = d.TT_ID_MASTER
					WHERE d.IN_ID = g.IN_ID_INCOME OR d.IN_ID = g.IN_ID
				) AS ID_DEL_SUM, ID_DEL_DISCOUNT,
				ID_ACTION, ID_RESTORE, ID_MON_CNT,
				(
					SELECT SUM(h.ID_SUP_PRICE_NDS)	
					FROM 
						Income.Incomes g INNER JOIN
						Income.IncomeDetailFullVIew h ON g.IN_ID = h.IN_ID
								AND h.SYS_ID_MASTER = d.SYS_ID_MASTER
								AND h.DT_ID_MASTER = d.DT_ID_MASTER
								AND h.NT_ID_MASTER = d.NT_ID_MASTER
								AND h.TT_ID_MASTER = d.TT_ID_MASTER
					WHERE d.IN_ID = g.IN_ID_INCOME OR d.IN_ID = g.IN_ID
				) AS ID_SUP_PRICE, ID_SUP_DISCOUNT, ID_PREPAY,
				ID_SUP_CONTRACT, ID_SUP_DATE, SYS_MAIN,
				DT_ID_MASTER, ID_SUP_MONTH
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
				) AND d.ID_ID = @ID_ID AND z.IN_ID_INCOME IS NULL
		) AS o_O	

	DECLARE @ID_DT_SUP_CON BIT

	IF (@ID_SUP_DATE IS NULL) OR (@ID_SUP_CONTRACT IS NULL)
		SET @ID_DT_SUP_CON = 0
	ELSE
		IF @ID_SUP_DATE <= @ID_SUP_CONTRACT
			SET @ID_DT_SUP_CON = 0
		ELSE
			SET @ID_DT_SUP_CON = 1

	DECLARE @ID_RESTORE_MAIN BIT
	DECLARE @ID_RESTORE_ADD BIT

	IF @ID_RESTORE = 1 AND @SYS_MAIN = 1
		SET @ID_RESTORE_MAIN = 1
	ELSE
		SET @ID_RESTORE_MAIN = 0

	IF @ID_RESTORE = 1 AND @SYS_MAIN = 0
		SET @ID_RESTORE_ADD = 1
	ELSE
		SET @ID_RESTORE_ADD = 0

	DECLARE @BC_ID UNIQUEIDENTIFIER

	DECLARE @BC_PREPAY BIT
	DECLARE @BC_MON_COUNT TINYINT
	DECLARE @BC_ACTION BIT
	DECLARE @BC_DT_SUP_CON BIT
	DECLARE @BC_RESTORE_ADD BIT
	DECLARE @BC_RESTORE_MAIN BIT
	DECLARE @BC_SUP_PRICE BIT
	DECLARE @BC_RES_PRICE BIT
	DECLARE @BC_PERCENT DECIMAL(8, 4)

	DECLARE BONUS CURSOR LOCAL FOR
		SELECT 
			BC_ID, BC_PREPAY, BC_MON_COUNT, BC_ACTION, 
			BC_DT_SUP_CON, BC_RESTORE_ADD, BC_RESTORE_MAIN,
			BC_SUP_PRICE, BC_RES_PRICE, BC_PERCENT
		FROM Salary.BonusConditionActive
		ORDER BY BC_ORDER

	OPEN BONUS

	FETCH NEXT FROM BONUS INTO
		@BC_ID, @BC_PREPAY, @BC_MON_COUNT, @BC_ACTION, 
		@BC_DT_SUP_CON, @BC_RESTORE_ADD, @BC_RESTORE_MAIN,
		@BC_SUP_PRICE, @BC_RES_PRICE, @BC_PERCENT

	DECLARE @TOTAL_SUM MONEY
	DECLARE @PERCENT DECIMAL(8, 4)

	WHILE @@FETCH_STATUS = 0
	BEGIN
		/*
		SELECT 'PREPAY' AS COL1, @ID_PREPAY AS COL2, ISNULL(@BC_PREPAY, @ID_PREPAY) AS COL3
		UNION ALL
		SELECT 'MON_CNT>=', ISNULL(@ID_MON_CNT, 0), ISNULL(@BC_MON_COUNT, ISNULL(@ID_MON_CNT, 0))
		UNION ALL
		SELECT 'ACTION', @ID_ACTION, ISNULL(@BC_ACTION, @ID_ACTION)
		UNION ALL
		SELECT 'DATE_CONTRACT', @ID_DT_SUP_CON, ISNULL(@BC_DT_SUP_CON, @ID_DT_SUP_CON)
		UNION ALL
		SELECT 'RESTORE_MAIN', @ID_RESTORE, ISNULL(@BC_RESTORE_MAIN, @ID_RESTORE)
		UNION ALL
		SELECT 'RESTORE_MAIN_SYS', @SYS_MAIN, ISNULL(@BC_RESTORE_MAIN, @SYS_MAIN)
		UNION ALL
		SELECT 'RESTORE_ADD', @ID_RESTORE, ISNULL(@BC_RESTORE_ADD, @ID_RESTORE)
		UNION ALL
		SELECT 'RESTORE_ADD_SYS', @SYS_MAIN, ISNULL(@BC_RESTORE_ADD, @SYS_MAIN)
		*/
		IF
			(@ID_PREPAY = ISNULL(@BC_PREPAY, @ID_PREPAY)) AND
			(ISNULL(@ID_MON_CNT, 0) >= ISNULL(@BC_MON_COUNT, ISNULL(@ID_MON_CNT, 0))) AND
			(@ID_ACTION = ISNULL(@BC_ACTION, @ID_ACTION)) AND
			(@ID_DT_SUP_CON = ISNULL(@BC_DT_SUP_CON, @ID_DT_SUP_CON)) AND
			(@ID_RESTORE_MAIN = ISNULL(@BC_RESTORE_MAIN, @ID_RESTORE_MAIN)) AND		
			(@ID_RESTORE_ADD = ISNULL(@BC_RESTORE_ADD, @ID_RESTORE_ADD))
		BEGIN
			IF @BC_SUP_PRICE = 1
				SET @TOTAL_SUM = @ID_SUP_MONTH
			ELSE IF @BC_RES_PRICE = 1
				SET @TOTAL_SUM = @ID_DEL_SUM

			SET @TOTAL_SUM = @TOTAL_SUM * @BC_PERCENT / 100
			BREAK
		END
	
		FETCH NEXT FROM BONUS INTO
			@BC_ID, @BC_PREPAY, @BC_MON_COUNT, @BC_ACTION, 
			@BC_DT_SUP_CON, @BC_RESTORE_ADD, @BC_RESTORE_MAIN,
			@BC_SUP_PRICE, @BC_RES_PRICE, @BC_PERCENT
	END

	SET @RESULT = @TOTAL_SUM	

	CLOSE BONUS
	DEALLOCATE BONUS
	
	
	RETURN @RESULT
END

