USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [USR].[USRComplectNumberView]
WITH SCHEMABINDING
AS
	SELECT
		UD_ID, dbo.DistrString(b.SystemShortName, UD_DISTR, UD_COMP) AS UD_NAME,
		b.SystemNumber AS UD_SYS, a.UD_DISTR, a.UD_COMP
	FROM USR.USRData a
	INNER JOIN dbo.SystemTable b ON a.UD_ID_HOST = b.HostID
GO
