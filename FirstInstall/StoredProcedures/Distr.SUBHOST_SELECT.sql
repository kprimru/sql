USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[SUBHOST_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*, ID AS ID_MASTER
	FROM	[Distr].[Subhost]
	ORDER BY NAME

	SELECT	@RC = @@ROWCOUNT
END
GRANT EXECUTE ON [Distr].[SUBHOST_SELECT] TO rl_distr_income_rGRANT EXECUTE ON [Distr].[SUBHOST_SELECT] TO rl_distr_income_r;
GO