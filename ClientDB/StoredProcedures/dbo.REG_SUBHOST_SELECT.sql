USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REG_SUBHOST_SELECT]
	@SH_ID	VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @REG	VARCHAR(50)

	SELECT @REG = '(' + SH_REG + ')%' 
	FROM dbo.Subhost
	WHERE SH_ID = CONVERT(UNIQUEIDENTIFIER, @SH_ID)

	SELECT 
		SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, 
		TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect
	FROM dbo.RegNodeTable
	WHERE Comment LIKE @REG
	
	UNION
	
	SELECT 
		d.SystemName, d.DistrNumber, d.CompNumber, d.DistrType, d.TechnolType, d.NetCount, d.SubHost, 
		d.TransferCount, d.TransferLeft, d.Service, d.RegisterDate, d.Comment, d.Complect
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.SubhostComplect c ON b.HostID = c.SC_ID_HOST AND a.DistrNumber = c.SC_DISTR AND a.CompNumber = c.SC_COMP
		INNER JOIN dbo.RegNodeTable d ON d.Complect = a.Complect
	WHERE SC_ID_SUBHOST = @SH_ID
	
	UNION
	
	SELECT 
		a.SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, 
		TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect
	FROM 
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.SubhostComplect c ON b.HostID = c.SC_ID_HOST AND a.DistrNumber = c.SC_DISTR AND a.CompNumber = c.SC_COMP		
	WHERE SC_ID_SUBHOST = @SH_ID
END