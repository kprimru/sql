USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RegNodeMainDistrView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[RegNodeMainDistrView]  AS SELECT 1')
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
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.RegNodeMainDistrView(DistrNumber,SystemBaseName,CompNumber)] ON [dbo].[RegNodeMainDistrView] ([DistrNumber] ASC, [SystemBaseName] ASC, [CompNumber] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.RegNodeMainDistrView(MainDistrNumber,MainHostID,MainCompNumber)] ON [dbo].[RegNodeMainDistrView] ([MainDistrNumber] ASC, [MainHostID] ASC, [MainCompNumber] ASC);
GO
