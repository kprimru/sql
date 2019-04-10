USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WeightTree]
AS
DECLARE @t TABLE
		(
			MasterID	UNIQUEIDENTIFIER NULL,
			DetailID	UNIQUEIDENTIFIER,
			Name		NVARCHAR(200)			
		)



INSERT INTO @t
	SELECT
		NULL,
		newid(),
		S.SystemName				
	FROM
		dbo.Weight W
		INNER JOIN dbo.SystemTable S ON S.SystemBaseName=W.Sys
	GROUP BY S.SystemName



INSERT INTO @t
	SELECT
		T.DetailID,
		newid(),
		ST.SST_SHORT
	FROM
		dbo.Weight W
		INNER JOIN dbo.SystemTable S ON S.SystemBaseName=W.Sys
		INNER JOIN Din.SystemType ST ON ST.SST_REG=W.SysType
		INNER JOIN @t T ON T.Name=S.SystemName
	GROUP BY T.DetailID, ST.SST_SHORT



INSERT INTO @t
	SELECT
		TT.DetailID,
		newid(),
		NT.NT_SHORT
	FROM
		dbo.Weight W
		INNER JOIN dbo.SystemTable S ON S.SystemBaseName=W.Sys
		INNER JOIN Din.SystemType ST ON ST.SST_REG=W.SysType
		INNER JOIN Din.NetType NT ON NT.NT_NET=W.NetCount AND NT.NT_TECH=W.NetTech AND NT.NT_ODON=W.NetOdon AND NT.NT_ODOFF=W.NetOdoff
		INNER JOIN @t T ON T.Name=S.SystemName
		INNER JOIN @t TT ON TT.Name=ST.SST_SHORT AND TT.MasterID=T.DetailID
		
	GROUP BY TT.DetailID, NT.NT_SHORT



INSERT INTO @t
	SELECT
		TTT.DetailID,
		newid(),
		'Ñ '+CAST(W.Date AS NVARCHAR(11))+' - '+CAST(W.Weight AS NVARCHAR)
	FROM
		dbo.Weight W
		INNER JOIN dbo.SystemTable S ON S.SystemBaseName=W.Sys
		INNER JOIN Din.SystemType ST ON ST.SST_REG=W.SysType
		INNER JOIN Din.NetType NT ON NT.NT_NET=W.NetCount AND NT.NT_TECH=W.NetTech AND NT.NT_ODON=W.NetOdon AND NT.NT_ODOFF=W.NetOdoff
		INNER JOIN @t T ON T.Name=S.SystemName
		INNER JOIN @t TT ON TT.Name=ST.SST_SHORT AND TT.MasterID=T.DetailID
		INNER JOIN @t TTT ON TTT.Name=NT.NT_SHORT AND TTT.MasterID=TT.DetailID
	GROUP BY TTT.DetailID, 'Ñ '+CAST(W.Date AS NVARCHAR(11))+' - '+CAST(W.Weight AS NVARCHAR)



SELECT *
FROM @t