USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SUBHOST_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(LAST)
	FROM	Distr.Subhost
END
GO
GRANT EXECUTE ON [Distr].[SUBHOST_LAST] TO rl_distr_income_r;
GO
