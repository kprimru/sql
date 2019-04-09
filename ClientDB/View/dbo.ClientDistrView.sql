USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ClientDistrView]
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
