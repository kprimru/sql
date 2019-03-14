USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[DISTR_TYPE_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(DTMS_LAST)
	FROM	Distr.DistrType
END
