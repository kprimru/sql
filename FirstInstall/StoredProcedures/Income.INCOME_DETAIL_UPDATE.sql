﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_DETAIL_UPDATE]
	@ID_ID				UNIQUEIDENTIFIER,
	@SYS_ID				UNIQUEIDENTIFIER,
	@DT_ID				UNIQUEIDENTIFIER,
	@NT_ID				UNIQUEIDENTIFIER,
	@TT_ID				UNIQUEIDENTIFIER,
	@ID_COUNT			TINYINT,
	@ID_DEL_SUM			MONEY,
	@ID_DEL_PRICE		MONEY,
	@ID_DEL_DISCOUNT	DECIMAL(8, 4),
	@ID_ACTION			BIT,
	@ID_RESTORE			BIT,
	@ID_EXCHANGE		BIT,
	@ID_ID_FIRST_MON	UNIQUEIDENTIFIER,
	@ID_MON_CNT			TINYINT,
	@ID_SUP_PRICE		MONEY,
	@ID_SUP_DISCOUNT	DECIMAL(8, 4),
	@ID_SUP_MONTH		MONEY,
	@ID_LOCK			BIT,
	@ID_NOTE			VARCHAR(250),
	@ID_ID_FULL_PAY		UNIQUEIDENTIFIER = NULL,
	@ID_SALARY			MONEY = NULL,
	@ID_INSTALL			BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID_ID, @OLD OUTPUT


	UPDATE	Income.IncomeDetail
	SET		ID_ID_SYSTEM	=	@SYS_ID,
			ID_ID_TYPE		=	@DT_ID,
			ID_ID_NET		=	@NT_ID,
			ID_ID_TECH		=	@TT_ID,
			ID_COUNT		=	@ID_COUNT,
			ID_DEL_SUM		=	@ID_DEL_SUM,
			ID_DEL_PRICE	=	@ID_DEL_PRICE,
			ID_DEL_DISCOUNT	=	@ID_DEL_DISCOUNT,
			ID_ACTION		=	@ID_ACTION,
			ID_RESTORE		=	@ID_RESTORE,
			ID_EXCHANGE		=	@ID_EXCHANGE,
			ID_ID_FIRST_MON	=	@ID_ID_FIRST_MON,
			ID_MON_CNT		=	@ID_MON_CNT,
			ID_SUP_PRICE	=	@ID_SUP_PRICE,
			ID_SUP_DISCOUNT	=	@ID_SUP_DISCOUNT,
			ID_SUP_MONTH	=	@ID_SUP_MONTH,
			ID_LOCK			=	@ID_LOCK,
			ID_NOTE			=	@ID_NOTE,
			ID_ID_FULL_PAY	=	@ID_ID_FULL_PAY,
			ID_SALARY		=	@ID_SALARY,
			ID_INSTALL		=	@ID_INSTALL
	WHERE	ID_ID	=	@ID_ID

	UPDATE Install.InstallDetail
	SET IND_ID_NET = @NT_ID,
		IND_ID_TECH = @TT_ID,
		IND_ID_TYPE = @DT_ID
	WHERE IND_ID_INCOME = @ID_ID

	UPDATE	Income.IncomeDetail
	SET		ID_ID_SYSTEM	=	@SYS_ID,
			ID_ID_TYPE		=	@DT_ID,
			ID_ID_NET		=	@NT_ID,
			ID_ID_TECH		=	@TT_ID,
			ID_COUNT		=	@ID_COUNT,
			ID_DEL_PRICE	=	@ID_DEL_PRICE,
			ID_DEL_DISCOUNT	=	@ID_DEL_DISCOUNT,
			ID_ACTION		=	@ID_ACTION,
			ID_RESTORE		=	@ID_RESTORE,
			ID_EXCHANGE		=	@ID_EXCHANGE,
			ID_ID_FIRST_MON	=	@ID_ID_FIRST_MON,
			ID_MON_CNT		=	@ID_MON_CNT,
			ID_SUP_DISCOUNT	=	@ID_SUP_DISCOUNT,
			ID_SUP_MONTH	=	@ID_SUP_MONTH,
			ID_LOCK			=	@ID_LOCK,
			ID_ID_FULL_PAY	=	@ID_ID_FULL_PAY,
			ID_SALARY		=	@ID_SALARY
	WHERE	ID_ID IN
			(
				SELECT a.ID_ID
				FROM
					Income.IncomeFullView a
				WHERE ID_ID_MASTER = @ID_ID
			)

	UPDATE Install.InstallDetail
	SET IND_ID_NET = @NT_ID,
		IND_ID_TECH = @TT_ID,
		IND_ID_TYPE = @DT_ID,
		IND_ID_SYSTEM = @SYS_ID
	WHERE IND_ID_INCOME IN
		(
			SELECT a.ID_ID
			FROM
				Income.IncomeFullView a
			WHERE ID_ID_MASTER = @ID_ID OR ID_ID = @ID_ID
		)

	EXEC Income.INCOME_DETAIL_FULL_DATE @ID_ID

	EXEC Common.PROTOCOL_VALUE_GET 'INCOME_DETAIL', @ID_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'INCOME_DETAIL', 'Редактирование', @ID_ID, @OLD, @NEW
END
GO
GRANT EXECUTE ON [Income].[INCOME_DETAIL_UPDATE] TO rl_income_w;
GO
