USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[RegNodeMainSystemView]
WITH SCHEMABINDING
AS
	SELECT     
		ID, 
		a.SystemName AS SystemBaseName,
		a.DistrNumber, a.CompNumber,
		Complect,
		e.HostID AS MainHostID, 
		CASE CHARINDEX('_', Complect)
			WHEN 0 THEN CONVERT(TINYINT, 1)
			ELSE CONVERT(TINYINT, RIGHT(Complect, LEN(Complect) - CHARINDEX('_', Complect)))
		END AS MainCompNumber,
		CASE CHARINDEX('_', Complect)
			WHEN 0 THEN CONVERT(INT, RIGHT(Complect, 6))
			ELSE 
				CASE CHARINDEX('#', Complect)
					WHEN 0 THEN CONVERT(INT, SUBSTRING(Complect, LEN(d.SystemBaseName) + 1, 6))
					ELSE CONVERT(INT, SUBSTRING(Complect, CHARINDEX('#', Complect) + 1, 6))
				END
		END AS MainDistrNumber,
		dbo.GET_HOST_BY_COMMENT(a.Comment) AS SubhostName
	FROM
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable d ON d.SystemBaseName = 
					CASE CHARINDEX('#', Complect) 
						WHEN 0 THEN 
							CASE CHARINDEX('_', Complect)
								WHEN 0 THEN LEFT(Complect, LEN(Complect) - 6)
								ELSE LEFT(Complect, LEN(Complect) - 6 - 3)
							END
						ELSE LEFT(Complect, CHARINDEX('#', Complect) - 1)
					END
		INNER JOIN dbo.Hosts e ON e.HostID = d.HostID
	WHERE a.Service = 0