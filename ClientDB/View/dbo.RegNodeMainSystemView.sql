USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RegNodeMainSystemView]
AS
	SELECT     
		ID, 
		a.SystemName AS SystemBaseName,
		a.DistrNumber, a.CompNumber,
		Complect,
		c.HostID AS MainHostID, 
		c.CompNumber AS MainCompNumber,
		c.DistrNumber AS MainDistrNumber,
		a.Service,
		dbo.GET_HOST_BY_COMMENT(a.Comment) AS SubhostName
	FROM
		dbo.RegNodeTable a
		CROSS APPLY dbo.[Complect@Extract](a.Complect) C
	WHERE a.Service = 0
