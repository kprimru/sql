USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[CLIENT_COMPLECT_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT dbo.DistrString(s.SystemShortName, f.UD_DISTR, f.UD_COMP) AS UD_NAME, UD_ID
	FROM USR.USRActiveView f
	INNER JOIN dbo.SystemTable s ON s.SystemID = f.UF_ID_SYSTEM
	WHERE UD_ID_CLIENT = @CLIENT AND UD_ACTIVE = 1
	ORDER BY UD_NAME
END
