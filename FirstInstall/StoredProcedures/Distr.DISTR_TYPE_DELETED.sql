USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[DISTR_TYPE_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Distr].[DistrTypeDeleted]
	
	SELECT	@RC = @@ROWCOUNT
END
