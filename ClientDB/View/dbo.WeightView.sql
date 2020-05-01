USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[WeightView]
WITH SCHEMABINDING
AS
	SELECT
		W.Date,
		W.Weight,
		S.SystemID,
		ST.SST_ID,
		NT.NT_ID
	FROM dbo.Weight W
	INNER JOIN dbo.SystemTable S ON W.Sys = S.SystemBaseName
	INNER JOIN Din.SystemType ST ON W.SysType = ST.SST_REG
	INNER JOIN Din.NetType NT ON W.NetCount = NT_NET
								AND W.NetTech = NT_TECH
								AND W.NetOdon = NT_ODON
								AND W.NetOdoff = NT_ODOFF