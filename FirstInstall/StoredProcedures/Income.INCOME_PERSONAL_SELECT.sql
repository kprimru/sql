USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Income].[INCOME_PERSONAL_SELECT]
	@ID_ID	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT
		@ID_ID AS ID_ID,
		PER_ID_MASTER, PER_ID, PER_NAME, IP_PERCENT, IP_PERCENT2
	FROM
		Income.IncomePersonalView
	WHERE	ID_ID IN
		(
			SELECT	ID
			FROM	Common.TableFromList(@ID_ID, ',')
		)
END
GRANT EXECUTE ON [Income].[INCOME_PERSONAL_SELECT] TO rl_income_personal;
GO