USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RegNodeCurrentView]
WITH SCHEMABINDING
AS
	SELECT     
		ID, SystemID, SystemShortName, SystemOrder,
		e.HostID, a.DistrType,
		dbo.DistrString(SystemShortName, DistrNumber, CompNumber) AS DistrStr,
		DistrNumber, CompNumber,
		DistrTypeID, DistrTypeName,		
		RegisterDate, Complect,
		DS_ID, DS_REG, DS_NAME, DS_INDEX,
		dbo.GET_HOST_BY_COMMENT(a.Comment) AS SubhostName
	FROM         
		dbo.RegNodeTable a 
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN Din.NetType f ON f.NT_NET = a.NetCount AND f.NT_TECH = a.TechnolType AND f.NT_ODON = a.ODON AND f.NT_ODOFF = a.ODOFF
		INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeId = f.NT_ID_MASTER
		INNER JOIN dbo.Hosts e ON e.HostID = b.HostID
		INNER JOIN dbo.DistrStatus ON DS_REG = Service
