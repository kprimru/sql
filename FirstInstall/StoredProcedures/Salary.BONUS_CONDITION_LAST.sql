USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Salary].[BONUS_CONDITION_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT	= MAX(BCMS_LAST)
	FROM	Salary.BonusCondition
END
