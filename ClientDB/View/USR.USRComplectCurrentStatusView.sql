USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [USR].[USRComplectCurrentStatusView]
WITH SCHEMABINDING
AS
	SELECT 
		UD_ID, dbo.DistrString(SystemShortName, UD_DISTR, UD_COMP) AS UD_NAME, Service AS UD_SERVICE,
		SystemNumber AS UD_SYS,
		UD_DISTR,
		UD_COMP
	FROM 
		USR.USRData a
		INNER JOIN dbo.SystemTable b ON a.UD_ID_HOST = b.HostID
		INNER JOIN dbo.RegNodeTable c ON b.SystemBaseName = c.SystemName AND UD_DISTR = DistrNumber AND UD_COMP = CompNumber
