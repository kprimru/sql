USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Din].[DinView]
WITH SCHEMABINDING
AS
	SELECT 
		DF_ID, DF_DISTR, DF_COMP, SystemID, HostID, SST_ID, NT_ID,
		dbo.DistrString(SystemShortName, DF_DISTR, DF_COMP) AS DIS_STR,
		DF_RIC, DF_CREATE,
		NT_SHORT, SST_SHORT, SystemOrder, SystemShortName, NT_TECH, NT_NET
	FROM 
		Din.DinFiles
		INNER JOIN dbo.SystemTable ON SystemID = DF_ID_SYS
		INNER JOIN Din.SystemType ON SST_ID = DF_ID_TYPE
		INNER JOIN Din.NetType ON NT_ID = DF_ID_NET