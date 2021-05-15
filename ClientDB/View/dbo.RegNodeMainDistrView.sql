USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[RegNodeMainDistrView]
WITH SCHEMABINDING
AS
	SELECT
		ID,
		R.SystemName AS SystemBaseName,
		R.DistrNumber, R.CompNumber,
		Complect,
		S.HostID AS MainHostID,
		[Reg].[Complect@Extract?Params](R.Complect, 'COMP') AS MainCompNumber,
		[Reg].[Complect@Extract?Params](R.Complect, 'DISTR') AS MainDistrNumber,
		--Cast([Reg].[Complect@Extract?Params](R.Complect, 'COMP') AS TinyInt) AS MainCompNumber,
		--Cast([Reg].[Complect@Extract?Params](R.Complect, 'DISTR') AS Int) AS MainDistrNumber,
		R.Service,
		dbo.SubhostByComment2(R.Comment, R.DistrNumber, R.SystemName) AS SubhostName
	FROM dbo.RegNodeTable R
	INNER JOIN dbo.SystemTable S ON S.SystemBaseName = [Reg].[Complect@Extract?Params](R.Complect, 'SYSTEM')
	WHERE R.Service = 0
GO
