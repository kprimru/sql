USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DBF_CACHE_SYNC_INTERNAL]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

    DECLARE @Distr Table
	(
		SYS_REG_NAME	VarChar(50)		NOT NULL,
		DIS_NUM			Int				NOT NULL,
		DIS_COMP_NUM	TinyInt			NOT NULL,
		PR_DATE			SmallDateTime	NOT NULL,
		UPD_DATE		DateTime		NOT NULL,
		PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)
	);

	DECLARE @Act Table
	(
		SYS_REG_NAME	VarChar(50)		NOT NULL,
		DIS_NUM			Int				NOT NULL,
		DIS_COMP_NUM	TinyInt			NOT NULL,
		PR_DATE			SmallDateTime	NOT NULL,
		AD_TOTAL_PRICE	Money			NOT NULL,
		PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)
	)

	DECLARE @Bill Table
	(
		SYS_REG_NAME	VarChar(50)		NOT NULL,
		DIS_NUM			Int				NOT NULL,
		DIS_COMP_NUM	TinyInt			NOT NULL,
		PR_DATE			SmallDateTime	NOT NULL,
		BD_TOTAL_PRICE	Money			NOT NULL,
		PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)
	)

	DECLARE @Income Table
	(
		SYS_REG_NAME	VarChar(50)		NOT NULL,
		DIS_NUM			Int				NOT NULL,
		DIS_COMP_NUM	TinyInt			NOT NULL,
		PR_DATE			SmallDateTime	NOT NULL,
		ID_PRICE		Money			NOT NULL,
		PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)
	)

	DECLARE @IncomeDate Table
	(
		SYS_REG_NAME	VarChar(50)		NOT NULL,
		DIS_NUM			Int				NOT NULL,
		DIS_COMP_NUM	TinyInt			NOT NULL,
		PR_DATE			SmallDateTime	NOT NULL,
		IN_DATE			SmallDateTime	NOT NULL,
		PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM, IN_DATE)
	)

	DECLARE @BillRest Table
	(
		SYS_REG_NAME	VarChar(50)		NOT NULL,
		DIS_NUM			Int				NOT NULL,
		DIS_COMP_NUM	TinyInt			NOT NULL,
		PR_DATE			SmallDateTime	NOT NULL,
		BD_REST			Money			NOT NULL,
		PRIMARY KEY CLUSTERED(DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)
	)

	BEGIN TRY

		-- вытаскиваем из DBF перечень дистрибутивов по которым что-то обновилось

		INSERT INTO @Distr(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, UPD_DATE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, UPD_DATE
		FROM [PC275-SQL\DELTA].[DBF].[Sync].[DistrFinancing];

		-- нет дистрибутивов - нет обработки
		IF @@ROWCOUNT = 0 BEGIN
			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

			RETURN;
		END;

        SET @Params =
            (
                SELECT
                    [Name] = 'DISTRS',
                    [Value] =
                        (
                            SELECT
                                SYS_REG_NAME,
                                DIS_NUM,
                                DIS_COMP_NUM,
                                PR_DATE
                            FROM @Distr
                            FOR XML RAW('DISTR')
                        )
                FOR XML RAW('PARAM'), ROOT('PARAMS')
            );

        EXEC [Debug].[Execution@Point]
            @DebugContext   = @DebugContext,
            @Name           = 'Получили список дистрибутивов для синхронизации',
            @Params         = @Params;

        --BEGIN TRAN;

		-- и забираем по этим дистрибутивам данные
		INSERT INTO @Act(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE)
		SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE, SUM(A.AD_TOTAL_PRICE)
		FROM @Distr D
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.ActAllIXView A WITH(NOEXPAND) ON	D.SYS_REG_NAME	= A.SYS_REG_NAME
																			AND	D.DIS_NUM		= A.DIS_NUM
																			AND D.DIS_COMP_NUM	= A.DIS_COMP_NUM
																			AND D.PR_DATE		= A.PR_DATE
		GROUP BY D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE;

		INSERT INTO @Bill(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE)
		SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE, B.BD_TOTAL_PRICE
		FROM @Distr D
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.BillAllIXView B WITH(NOEXPAND) ON	D.SYS_REG_NAME	= B.SYS_REG_NAME
																			AND	D.DIS_NUM		= B.DIS_NUM
																			AND D.DIS_COMP_NUM	= B.DIS_COMP_NUM
																			AND D.PR_DATE		= B.PR_DATE;

		INSERT INTO @Income(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE)
		SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE, I.ID_PRICE
		FROM @Distr D
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.IncomeAllIXView I WITH(NOEXPAND) ON	D.SYS_REG_NAME	= I.SYS_REG_NAME
																				AND	D.DIS_NUM		= I.DIS_NUM
																				AND D.DIS_COMP_NUM	= I.DIS_COMP_NUM
																				AND D.PR_DATE		= I.PR_DATE;

		INSERT INTO @IncomeDate(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE)
		SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE, I.IN_DATE
		FROM @Distr D
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.IncomeDateIXView I WITH(NOEXPAND) ON	D.SYS_REG_NAME	= I.SYS_REG_NAME
																				AND	D.DIS_NUM		= I.DIS_NUM
																				AND D.DIS_COMP_NUM	= I.DIS_COMP_NUM
																				AND D.PR_DATE		= I.PR_DATE;

		INSERT INTO @BillRest(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_REST)
		SELECT D.SYS_REG_NAME, D.DIS_NUM, D.DIS_COMP_NUM, D.PR_DATE, B.BD_REST
		FROM @Distr D
		INNER JOIN [PC275-SQL\DELTA].DBF.dbo.BillAllRestView B WITH(NOEXPAND) ON	D.SYS_REG_NAME	= B.SYS_REG_NAME
																				AND	D.DIS_NUM		= B.DIS_NUM
																				AND D.DIS_COMP_NUM	= B.DIS_COMP_NUM
																				AND D.PR_DATE		= B.PR_DATE;

		-- теперь уже локально начинаем разбираться, что из этого добавить, что изменить, а что удалить

		-----------------------------------
		---------------АКТЫ----------------
		-----------------------------------
		--/*
		DELETE A
		FROM dbo.DBFAct A
		INNER JOIN @Distr D ON	D.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	D.DIS_NUM		= A.DIS_NUM
							AND D.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND D.PR_DATE		= A.PR_DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @Act Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		UPDATE A
		SET AD_TOTAL_PRICE = Z.AD_TOTAL_PRICE
		FROM dbo.DBFAct A
		INNER JOIN @Act Z ON	Z.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	Z.DIS_NUM		= A.DIS_NUM
							AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND Z.PR_DATE		= A.PR_DATE
		WHERE A.AD_TOTAL_PRICE != Z.AD_TOTAL_PRICE;

		INSERT INTO dbo.DBFAct(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, AD_TOTAL_PRICE
		FROM @Act A
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DBFAct Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		-----------------------------------
		---------------СЧЕТА---------------
		-----------------------------------

		DELETE A
		FROM dbo.DBFBill A
		INNER JOIN @Distr D ON	D.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	D.DIS_NUM		= A.DIS_NUM
							AND D.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND D.PR_DATE		= A.PR_DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @Bill Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		UPDATE A
		SET BD_TOTAL_PRICE = Z.BD_TOTAL_PRICE
		FROM dbo.DBFBill A
		INNER JOIN @Bill Z ON	Z.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	Z.DIS_NUM		= A.DIS_NUM
							AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND Z.PR_DATE		= A.PR_DATE
		WHERE A.BD_TOTAL_PRICE != Z.BD_TOTAL_PRICE;

		INSERT INTO dbo.DBFBill(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_TOTAL_PRICE
		FROM @Bill A
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DBFBill Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		-----------------------------------
		---------------ПЛАТЕЖИ-------------
		-----------------------------------

		DELETE A
		FROM dbo.DBFIncome A
		INNER JOIN @Distr D ON	D.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	D.DIS_NUM		= A.DIS_NUM
							AND D.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND D.PR_DATE		= A.PR_DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @Income Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		UPDATE A
		SET ID_PRICE = Z.ID_PRICE
		FROM dbo.DBFIncome A
		INNER JOIN @Income Z ON	Z.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	Z.DIS_NUM		= A.DIS_NUM
							AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND Z.PR_DATE		= A.PR_DATE
		WHERE IsNull(A.ID_PRICE, 0) != IsNull(Z.ID_PRICE, 0);

		INSERT INTO dbo.DBFIncome(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, ID_PRICE
		FROM @Income A
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DBFIncome Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		-----------------------------------
		---------------ОСТАТКИ ПО СЧЕТАМ---
		-----------------------------------

		DELETE A
		FROM dbo.DBFBillRest A
		INNER JOIN @Distr D ON	D.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	D.DIS_NUM		= A.DIS_NUM
							AND D.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND D.PR_DATE		= A.PR_DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @BillRest Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		UPDATE A
		SET BD_REST = Z.BD_REST
		FROM dbo.DBFBillRest A
		INNER JOIN @BillRest Z ON	Z.SYS_REG_NAME	= A.SYS_REG_NAME
								AND	Z.DIS_NUM		= A.DIS_NUM
								AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
								AND Z.PR_DATE		= A.PR_DATE
		WHERE A.BD_REST != Z.BD_REST;

		INSERT INTO dbo.DBFBillRest(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_REST)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, BD_REST
		FROM @BillRest A
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DBFBillRest Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
			);

		-----------------------------------
		---------------ДАТЫ ОПЛАТЫ---------
		-----------------------------------

		DELETE A
		FROM dbo.DBFIncomeDate A
		INNER JOIN @Distr D ON	D.SYS_REG_NAME	= A.SYS_REG_NAME
							AND	D.DIS_NUM		= A.DIS_NUM
							AND D.DIS_COMP_NUM	= A.DIS_COMP_NUM
							AND D.PR_DATE		= A.PR_DATE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @IncomeDate Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
					AND	Z.IN_DATE		= A.IN_DATE
			);

		INSERT INTO dbo.DBFIncomeDate(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE)
		SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE, IN_DATE
		FROM @IncomeDate A
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.DBFIncomeDate Z
				WHERE	Z.SYS_REG_NAME	= A.SYS_REG_NAME
					AND	Z.DIS_NUM		= A.DIS_NUM
					AND Z.DIS_COMP_NUM	= A.DIS_COMP_NUM
					AND Z.PR_DATE		= A.PR_DATE
					AND	Z.IN_DATE		= A.IN_DATE
			);
		--*/

		-- удаляем из DBF дистрибутивы которые синхронизировали.
		-- Если UPD_DATE не совпадает, значит были еще изменения и из синхронизации дистрибутив не удаляем
		DELETE S
		FROM [PC275-SQL\DELTA].[DBF].[Sync].[DistrFinancing] S
		INNER JOIN @Distr D ON	D.SYS_REG_NAME	= S.SYS_REG_NAME
							AND	D.DIS_NUM		= S.DIS_NUM
							AND D.DIS_COMP_NUM	= S.DIS_COMP_NUM
							AND D.PR_DATE		= S.PR_DATE
							AND D.UPD_DATE		= S.UPD_DATE;

        /*
        IF @@TranCount > 0
            COMMIT TRAN;
        */

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
	    /*
	    IF @@TranCount > 0
	        ROLLBACK TRAN;
	    */

		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
