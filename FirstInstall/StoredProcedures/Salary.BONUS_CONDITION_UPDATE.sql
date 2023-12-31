USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[BONUS_CONDITION_UPDATE]
	@BC_ID				UNIQUEIDENTIFIER,
	@BC_PREPAY			BIT,
	@BC_MON_COUNT		TINYINT,
	@BC_ACTION			BIT,
	@BC_EXCHANGE		BIT,
	@BC_DT_SUP_CON		BIT,
	@BC_RESTORE_MAIN	BIT,
	@BC_RESTORE_ADD		BIT,
	@BC_SUP_PRICE		MONEY,
	@BC_RES_PRICE		MONEY,
	@BC_PERCENT			DECIMAL(8, 4),
	@BC_ORDER			INT,
	@BC_DATE			SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @BC_ID_MASTER UNIQUEIDENTIFIER

	SELECT @BC_ID_MASTER = BC_ID_MASTER
	FROM Salary.BonusConditionDetail
	WHERE BC_ID = @BC_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'BONUS_CONDITION', @BC_ID_MASTER, @OLD OUTPUT

	UPDATE	Salary.BonusConditionDetail
	SET		BC_PREPAY		=	@BC_PREPAY,
			BC_MON_COUNT	=	@BC_MON_COUNT,
			BC_ACTION		=	@BC_ACTION,
			BC_EXCHANGE		=	@BC_EXCHANGE,
			BC_DT_SUP_CON	=	@BC_DT_SUP_CON,
			BC_RESTORE_MAIN	=	@BC_RESTORE_MAIN,
			BC_RESTORE_ADD	=	@BC_RESTORE_ADD,
			BC_SUP_PRICE	=	@BC_SUP_PRICE,
			BC_RES_PRICE	=	@BC_RES_PRICE,
			BC_PERCENT		=	@BC_PERCENT,
			BC_ORDER		=	@BC_ORDER,
			BC_DATE			=	@BC_DATE
	WHERE	BC_ID			=	@BC_ID

	UPDATE	Salary.BonusCondition
	SET		BCMS_LAST	=	GETDATE()
	WHERE	BCMS_ID	=
		(
			SELECT	BC_ID_MASTER
			FROM	Salary.BonusConditionDetail
			WHERE	BC_ID	=	@BC_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'BONUS_CONDITION', @BC_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'BONUS_CONDITION', '��������������', @BC_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Salary].[BONUS_CONDITION_UPDATE] TO rl_bonus_condition_u;
GO
