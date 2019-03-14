USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[SYSTEM_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT [Distr].[SystemDeleted].*, HST_ID_MASTER, HST_NAME
	FROM 
		[Distr].[SystemDeleted]	INNER JOIN
		[Distr].[HostLast]		ON HST_ID_MASTER = SYS_ID_HOST
	
	SELECT @RC = @@ROWCOUNT
END
