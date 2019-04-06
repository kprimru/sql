USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salary].[BONUS_CONDITION_REFRESH_ORDER]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	BONUS CURSOR LOCAL FOR
		SELECT		BC_ID
		FROM		Salary.BonusConditionActive
		ORDER BY	BC_ORDER

	OPEN BONUS

	DECLARE @ORDER INT
	DECLARE @BC_ID UNIQUEIDENTIFIER

	FETCH NEXT FROM BONUS INTO @BC_ID

	SET @ORDER = 10

	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE	Salary.BonusConditionDetail
		SET		BC_ORDER	=	@ORDER
		WHERE	BC_ID		=	@BC_ID

		SET		@ORDER		=	@ORDER + 10

		FETCH NEXT FROM BONUS INTO @BC_ID
	END

	CLOSE BONUS
	DEALLOCATE BONUS
END
