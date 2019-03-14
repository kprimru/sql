USE [FirstInstall]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Distr].[WEIGHT_LAST]
	@DT	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	@DT = MAX(WGMS_LAST)
	FROM	Distr.Weight
END
