USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[KGS_DISTR_SELECT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		KD_ID, 
		dbo.DistrString(SystemShortName, KD_DISTR, KD_COMP) AS DIS_STR,
		KD_ID_SYS, KD_DISTR, KD_COMP
	FROM 
		dbo.KGSDistr
		INNER JOIN dbo.SystemTable ON KD_ID_SYS = SystemID
	WHERE KD_ID_LIST = @ID
	ORDER BY SystemOrder, KD_DISTR
END