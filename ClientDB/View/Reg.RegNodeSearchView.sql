USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reg].[RegNodeSearchView]
WITH SCHEMABINDING
AS
	SELECT 
		a.ID,
		SystemID, SystemShortName, SystemOrder, HostID,
		DistrNumber, CompNumber,
		dbo.DistrString(SystemShortName, DistrNumber, CompNumber) AS DistrStr,
		DistrType, SST_ID, SST_SHORT, NT_ID, NT_SHORT, NT_TECH, TransferCount, TransferLeft, Comment, Complect, RegisterDate, 
		DS_ID, DS_INDEX, DS_REG, DS_NAME,
		dbo.SubhostByComment(Comment, DistrNumber) AS SubhostName,
		SystemBaseName,
		DIstrTypeId, DistrTypeName, a.Service
	FROM
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN Din.SystemType c ON a.DistrType = c.SST_REG
		INNER JOIN Din.NetType d ON d.NT_NET = a.NetCount AND d.NT_TECH = a.TechnolType AND d.NT_ODON = a.ODON AND d.NT_ODOFF = a.ODOFF
		INNER JOIN dbo.DistrStatus ON DS_REG = Service
		INNER JOIN dbo.DistrTypeTable t ON t.DistrTypeId = d.NT_ID_MASTER
