USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientDistrView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ClientDistrView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ClientDistrView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID, a.ID_CLIENT,
		b.SystemID, b.SystemShortName, b.SystemOrder, b.SystemBaseName, b.SystemReg, b.SystemBaseCheck,
		a.DISTR, a.COMP,
		dbo.DistrString(b.SystemShortName, a.DISTR, a.COMP) AS DistrStr,
		SystemTypeID, SystemTypeName,
		DistrTypeID, DistrTypeName, DistrTypeBaseCheck,
		e.HostID, e.HostShort,
		f.DS_ID, f.DS_REG, f.DS_INDEX, f.DS_NAME
	FROM
		dbo.ClientDistr a
		INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
		INNER JOIN dbo.SystemTypeTable c ON c.SystemTypeID = a.ID_TYPE
		INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = a.ID_NET
		INNER JOIN dbo.Hosts e ON e.HostID = ID_HOST
		INNER JOIN dbo.DistrStatus f ON f.DS_ID = a.ID_STATUS
	WHERE STATUS = 1

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientDistrView(DISTR,HostID,COMP)] ON [dbo].[ClientDistrView] ([DISTR] ASC, [HostID] ASC, [COMP] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrView(DISTR,HostID,COMP)+(ID_CLIENT)] ON [dbo].[ClientDistrView] ([DISTR] ASC, [HostID] ASC, [COMP] ASC) INCLUDE ([ID_CLIENT]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrView(DS_REG)+(COMP,DISTR,ID_CLIENT,SystemID,SystemShortName)] ON [dbo].[ClientDistrView] ([DS_REG] ASC) INCLUDE ([COMP], [DISTR], [ID_CLIENT], [SystemID], [SystemShortName]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrView(DS_REG,SystemBaseName)+(ID_CLIENT,SystemID,SystemOrder,DISTR,COMP,DistrStr)] ON [dbo].[ClientDistrView] ([DS_REG] ASC, [SystemBaseName] ASC) INCLUDE ([ID_CLIENT], [SystemID], [SystemOrder], [DISTR], [COMP], [DistrStr]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrView(ID)] ON [dbo].[ClientDistrView] ([ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDistrView(ID_CLIENT,DS_REG,DistrTypeBaseCheck,SystemBaseCheck)+INCL] ON [dbo].[ClientDistrView] ([ID_CLIENT] ASC, [DS_REG] ASC, [DistrTypeBaseCheck] ASC, [SystemBaseCheck] ASC) INCLUDE ([COMP], [DISTR], [DistrStr], [DistrTypeID], [DistrTypeName], [DS_ID], [DS_INDEX], [HostID], [SystemBaseName], [SystemID], [SystemOrder], [SystemTypeID], [SystemTypeName], [DS_NAME], [SystemReg], [SystemShortName], [ID]);
GO
GRANT SELECT ON [dbo].[ClientDistrView] TO COMPLECTBASE;
GO
