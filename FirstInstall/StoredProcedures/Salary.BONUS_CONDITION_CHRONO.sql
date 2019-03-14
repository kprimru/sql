USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Salary].[BONUS_CONDITION_CHRONO]
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
	@BC_ID_MASTER		UNIQUEIDENTIFIER,
	@BC_END				SMALLDATETIME,
	@BC_ID				UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'BONUS_CONDITION', @BC_ID_MASTER, @OLD OUTPUT

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	DECLARE @MASTERID UNIQUEIDENTIFIER


	BEGIN TRANSACTION

	BEGIN TRY
		UPDATE	Salary.BonusConditionDetail
		SET		BC_END	=	@BC_END,
				BC_REF	=	2
		WHERE	BC_ID	=	@BC_ID	

		UPDATE	Salary.BonusCondition
		SET		BCMS_LAST	=	GETDATE()
		WHERE	BCMS_ID		=	@BC_ID_MASTER

		INSERT INTO 
				Salary.BonusConditionDetail(
					BC_ID_MASTER,
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
					BC_DATE
				)
		OUTPUT INSERTED.BC_ID INTO @TBL
		VALUES	(
					@BC_ID_MASTER,
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
					@BC_DATE
				)

		SELECT	@BC_ID = ID
		FROM	@TBL		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION
	END CATCH

	IF @@TRANCOUNT > 0
        COMMIT TRANSACTION

	EXEC Common.PROTOCOL_VALUE_GET 'BONUS_CONDITION', @BC_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'BONUS_CONDITION', '��������������� ���������', @BC_ID_MASTER, @OLD, @NEW
END

