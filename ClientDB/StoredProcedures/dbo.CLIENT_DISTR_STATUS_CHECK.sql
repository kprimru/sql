USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISTR_STATUS_CHECK]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @STAT UNIQUEIDENTIFIER
	
	SELECT @STAT = DS_ID
	FROM dbo.DistrStatus
	WHERE DS_REG = 2
	
	UPDATE a
	SET ID_STATUS = @STAT
	FROM 
		dbo.ClientDistr a
		INNER JOIN dbo.SystemTable b ON a.ID_SYSTEM = b.SystemID
		INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
		INNER JOIN dbo.DistrStatus d ON d.DS_ID = a.ID_STATUS
	WHERE DS_REG = 1 AND Service = 2 AND a.STATUS = 1
END
