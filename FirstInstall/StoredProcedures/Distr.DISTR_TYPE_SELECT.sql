USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[DISTR_TYPE_SELECT]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Distr].[DistrTypeActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[DISTR_TYPE_SELECT] TO rl_distr_type_r;
GO
