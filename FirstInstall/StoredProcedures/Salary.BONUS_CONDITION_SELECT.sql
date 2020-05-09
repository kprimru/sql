USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[BONUS_CONDITION_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Salary].[BonusConditionActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Salary].[BONUS_CONDITION_SELECT] TO rl_bonus_condition_r;
GO