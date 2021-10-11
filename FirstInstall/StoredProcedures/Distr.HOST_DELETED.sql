USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Distr].[HOST_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Distr].[HostDeleted]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Distr].[HOST_DELETED] TO rl_host_r;
GO
