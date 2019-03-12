USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DISTR_EXCHANGE_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@SYSTEM	INT OUTPUT,
	@NET	INT OUTPUT,
	@DISTR	VARCHAR(50) OUTPUT,
	@HOST	INT	OUTPUT,
	@DATE	SMALLDATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @SYSTEM = b.SystemID, @DATE = CONVERT(SMALLDATETIME, RegisterDate, 104)
	FROM 
		dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN dbo.SystemTable b ON b.HostID = a.HostID
		INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName 
										AND c.DistrNumber = a.DISTR 
										AND c.CompNumber = a.COMP
	WHERE a.ID = @ID AND a.SystemID <> b.SystemID
	
	SELECT @NET = d.DistrTypeID, @DATE = CONVERT(SMALLDATETIME, RegisterDate, 104)
	FROM 
		dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN dbo.SystemTable b ON b.HostID = a.HostID
		INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName 
										AND c.DistrNumber = a.DISTR 
										AND c.CompNumber = a.COMP
		INNER JOIN Din.NetType e ON e.NT_NET = c.NetCount AND e.NT_TECH = c.TechnolType AND e.NT_ODON = c.ODON AND e.NT_ODOFF = c.ODOFF
		INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeId = e.NT_ID_MASTER
	WHERE a.ID = @ID AND a.DistrTypeID <> d.DistrTypeID
	
	SELECT @DISTR = DistrStr, @HOST = HostID
	FROM dbo.ClientDistrView a WITH(NOEXPAND)
	WHERE ID = @ID
	
	IF (SELECT COUNT(*) FROM dbo.SystemTable WHERE HostID = @HOST) < 2 
		SET @HOST = NULL
END