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
CREATE UNIQUE CLUSTERED INDEX [UC_USR.USRComplectNumberView(UD_ID,UD_SYS)] ON [USR].[USRComplectNumberView] ([UD_ID] ASC, [UD_SYS] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRComplectNumberView(UD_DISTR,UD_SYS,UD_COMP)] ON [USR].[USRComplectNumberView] ([UD_DISTR] ASC, [UD_SYS] ASC, [UD_COMP] ASC);
GO
