USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegNodeSearchView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegNodeSearchView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [Reg].[RegNodeSearchView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID,
		SystemID, SystemShortName, SystemOrder, HostID,
		DistrNumber, CompNumber,
		dbo.DistrString(SystemShortName, DistrNumber, CompNumber) AS DistrStr,
		DistrType, SST_ID, SST_SHORT, NT_ID, NT_SHORT, NT_TECH, TransferCount, TransferLeft, Comment, Complect, RegisterDate,
		DS_ID, DS_INDEX, DS_REG, DS_NAME,
		dbo.SubhostByComment2(Comment, DistrNumber, a.SystemName) AS SubhostName,
		SystemBaseName,
		DIstrTypeId, DistrTypeName, a.Service, FirstReg
	FROM
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN Din.SystemType c ON a.DistrType = c.SST_REG
		INNER JOIN Din.NetType d ON d.NT_NET = a.NetCount AND d.NT_TECH = a.TechnolType AND d.NT_ODON = a.ODON AND d.NT_ODOFF = a.ODOFF
		INNER JOIN dbo.DistrStatus ON DS_REG = Service
		INNER JOIN dbo.DistrTypeTable t ON t.DistrTypeId = d.NT_ID_MASTER



GO
CREATE UNIQUE CLUSTERED INDEX [UC_Reg.RegNodeSearchView(ID)] ON [Reg].[RegNodeSearchView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Reg.RegNodeSearchView(Complect,DS_REG,DistrStr)+(CompNumber,DistrNumber,HostID,SystemBaseName,RegisterDate,SystemID,DIstrType] ON [Reg].[RegNodeSearchView] ([Complect] ASC, [DS_REG] ASC, [DistrStr] ASC) INCLUDE ([CompNumber], [DistrNumber], [HostID], [SystemBaseName], [RegisterDate], [SystemID], [DIstrTypeId], [DistrTypeName]);
CREATE NONCLUSTERED INDEX [IX_Reg.RegNodeSearchView(DistrNumber,CompNumber,HostID)+(SystemOrder,SystemID,Complect,DistrStr)] ON [Reg].[RegNodeSearchView] ([DistrNumber] ASC, [CompNumber] ASC, [HostID] ASC) INCLUDE ([SystemOrder], [SystemID], [Complect], [DistrStr]);
CREATE NONCLUSTERED INDEX [IX_Reg.RegNodeSearchView(DS_REG,DistrNumber,CompNumber,SystemBaseName)+(DIstrTypeId,SystemID)] ON [Reg].[RegNodeSearchView] ([DS_REG] ASC, [DistrNumber] ASC, [CompNumber] ASC, [SystemBaseName] ASC) INCLUDE ([DIstrTypeId], [SystemID]);
CREATE NONCLUSTERED INDEX [IX_Reg.RegNodeSearchView(DS_REG,SST_SHORT,NT_SHORT)+(SystemID,SystemOrder,HostID,DistrNumber,CompNumber,DistrStr,Complect,Subhos] ON [Reg].[RegNodeSearchView] ([DS_REG] ASC, [SST_SHORT] ASC, [NT_SHORT] ASC) INCLUDE ([SystemID], [SystemOrder], [HostID], [DistrNumber], [CompNumber], [DistrStr], [Complect], [SubhostName], [SystemBaseName]);
CREATE NONCLUSTERED INDEX [IX_Reg.RegNodeSearchView(DS_REG,SubhostName)+(Complect,SST_SHORT,SystemShortName,SystemOrder,HostID,DistrNumber,CompNumber,Distr] ON [Reg].[RegNodeSearchView] ([DS_REG] ASC, [SubhostName] ASC) INCLUDE ([Complect], [SST_SHORT], [SystemShortName], [SystemOrder], [HostID], [DistrNumber], [CompNumber], [DistrStr], [DistrType], [SST_ID], [NT_ID], [TransferLeft], [RegisterDate], [DS_INDEX], [DS_NAME], [DIstrTypeId], [DistrTypeName]);
CREATE NONCLUSTERED INDEX [IX_Reg.RegNodeSearchView(SubhostName)+(ID,HostID,DistrNumber,CompNumber,DistrStr,Comment)] ON [Reg].[RegNodeSearchView] ([SubhostName] ASC) INCLUDE ([ID], [HostID], [DistrNumber], [CompNumber], [DistrStr], [Comment]);
GO
