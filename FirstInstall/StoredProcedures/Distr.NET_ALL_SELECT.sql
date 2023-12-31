USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[NET_ALL_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	Distr.NetAll
	ORDER BY TECH, COEF, NET_COUNT

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[NET_ALL_SELECT] TO rl_distr_income_r;
GO
