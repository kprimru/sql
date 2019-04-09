USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_LIST_PREPARE]
	@SERVICE	NVARCHAR(MAX),
	@MANAGER	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT ServiceID, ServiceName
	FROM
		(
			SELECT ID
			FROM dbo.TableIDFromXML(@SERVICE)
	
			UNION
	
			SELECT ServiceID
			FROM 
				dbo.TableIDFromXML(@MANAGER)
				INNER JOIN dbo.ServiceTable ON ManagerID = ID
		) AS a
		INNER JOIN dbo.ServiceTable b ON b.ServiceID = a.ID
	ORDER BY ServiceName
END
