USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RegNodeView]
WITH SCHEMABINDING
AS
	SELECT     
		dbo.DistrString(ISNULL(b.SystemShortName, a.SystemName), a.DistrNumber, CompNumber) AS DistrStr, 
		a.SystemName, a.DistrNumber, a.CompNumber, 
		a.DistrType, a.NetCount, a.TechnolType, a.SubHost, a.Service, 
		a.RegisterDate, a.Comment, a.Complect, DS_NAME, 
		dbo.GET_HOST_BY_COMMENT(a.Comment) AS SubhostName,
		b.HostID
	FROM         
		dbo.RegNodeTable AS a INNER JOIN
		dbo.SystemTable AS b ON a.SystemName = b.SystemBaseName INNER JOIN
		dbo.DistrStatus AS c ON c.DS_REG = a.Service