USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[BONUS_CONDITION_INSERT]
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
	@BC_DATE			SMALLDATETIME,
	@BC_ID				UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'BONUS_CONDITION', NULL, @OLD OUTPUT



	DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

	DECLARE @MASTERID UNIQUEIDENTIFIER

	INSERT INTO Salary.BonusCondition(BCMS_ID)
	OUTPUT INSERTED.BCMS_ID INTO @TBL
	DEFAULT VALUES

	SELECT	@MASTERID = ID
	FROM	@TBL

	DELETE
	FROM	@TBL

	INSERT INTO
			Salary.BonusConditionDetail(
				BC_PREPAY,
				BC_MON_COUNT,
				BC_ACTION,
				BC_EXCHANGE,
				BC_DT_SUP_CON,
				BC_RESTORE_MAIN,
				BC_RESTORE_ADD,
				BC_SUP_PRICE,
				BC_RES_PRICE,
				BC_PERCENT,
				BC_ORDER,
				BC_DATE,
				BC_ID_MASTER
			)
	OUTPUT INSERTED.BC_ID INTO @TBL(ID)
	VALUES	(
				@BC_PREPAY,
				@BC_MON_COUNT,
				@BC_ACTION,
				@BC_EXCHANGE,
				@BC_DT_SUP_CON,
				@BC_RESTORE_MAIN,
				@BC_RESTORE_ADD,
				@BC_SUP_PRICE,
				@BC_RES_PRICE,
				@BC_PERCENT,
				@BC_ORDER,
				@BC_DATE,
				@MASTERID
			)

	SELECT	@BC_ID = ID
	FROM	@TBL

	EXEC Common.PROTOCOL_VALUE_GET 'BONUS_CONDITION', @MASTERID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'BONUS_CONDITION', '����� ������', @MASTERID, @OLD, @NEW


END

GO
GRANT EXECUTE ON [Salary].[BONUS_CONDITION_INSERT] TO rl_bonus_condition_i;
GO
