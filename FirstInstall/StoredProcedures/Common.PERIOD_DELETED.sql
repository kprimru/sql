USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[PERIOD_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Common].[PeriodDeleted]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Common].[PERIOD_DELETED] TO rl_period_r;
GO
