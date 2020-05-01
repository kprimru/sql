USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[HOST_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(HSTMS_LAST)
	FROM	Distr.Hosts
END
GRANT EXECUTE ON [Distr].[HOST_LAST] TO rl_host_r;
GO