USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONNECT_SYSTEM]
	@CLIENT	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DS_ON UNIQUEIDENTIFIER
	
	SELECT @DS_ON = DS_ID
	FROM dbo.DistrStatus
	WHERE DS_REG = 0
	
	SELECT 
		a.ID, 
		ClientFullName,
		dbo.DistrString(c.SystemShortName, a.DISTR, a.COMP) AS DistrStr,
		CONVERT(BIT, CASE
			WHEN EXISTS
				(
					SELECT *
					FROM 
						dbo.RegNodeTable z
						INNER JOIN dbo.SystemTable y ON z.SystemName = y.SystemBaseName
					WHERE z.DistrNumber = a.DISTR AND z.CompNumber = a.COMP
						AND y.HostID = c.HostID
						AND Service = 0
				) THEN 1
			ELSE 0
		END) AS CONNECT,
		(
			SELECT TOP 1 COMPLECT 
			FROM dbo.RegNodeTable z 
			WHERE a.DISTR = z.DistrNumber 
				AND a.COMP = z.CompNumber 
				AND c.SystemBaseName = z.SystemName
		) AS COMPLECT
	FROM 
		dbo.ClientDistr a
		INNER JOIN dbo.TableIDFromXML(@CLIENT) b ON a.ID_CLIENT = b.ID
		INNER JOIN dbo.SystemTable c ON c.SystemID = a.ID_SYSTEM
		INNER JOIN dbo.ClientTable d ON d.ClientID = a.ID_CLIENT
	WHERE a.STATUS = 1
	ORDER BY ClientFullName, SystemOrder, DISTR, COMP
END