USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_MANAGER_FILTER]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@SENDER	NVARCHAR(MAX),
	@NOTE	NVARCHAR(256),
	@STATUS	NVARCHAR(MAX),
	@TYPE	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientID, ClientFullName, DATE, SENDER, SHORT, 
		CASE SHORT 
			WHEN '' THEN '' 
			ELSE SHORT + CHAR(10) 
		END + NOTE AS NOTE, 
		ServiceStatusIndex,
		'' AS TP_NAME
	FROM 
		Task.Tasks a
		INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
		INNER JOIN dbo.ClientTable c ON c.ClientID = a.ID_CLIENT
		INNER JOIN dbo.ServiceStatusTable d ON c.StatusID = d.ServiceStatusID
	WHERE SENDER <> '�������'
		AND a.STATUS = 1
		AND (a.DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (a.DATE <= @END OR @END IS NULL)
		AND (a.SENDER IN (SELECT ID FROM dbo.TableStringFromXML(@SENDER)) OR @SENDER IS NULL)
		AND (a.NOTE LIKE @NOTE OR @NOTE IS NULL)
		AND (c.StatusID IN (SELECT ID FROM dbo.TableIDFromXML(@STATUS)) OR @STATUS IS NULL)
	
	UNION ALL
	
	SELECT 
		ClientID, ClientFullName, dbo.DateOf(DATE), PERSONAL, '', 
		NOTE, 
		ServiceStatusIndex,
		b.NAME
	FROM 
		dbo.ClientContact a
		INNER JOIN dbo.ClientTable c ON c.ClientID = a.ID_CLIENT
		INNER JOIN dbo.ServiceStatusTable d ON c.StatusID = d.ServiceStatusID
		INNER JOIN dbo.ClientContactType b ON a.ID_TYPE = b.ID
	WHERE a.STATUS = 1
		AND (a.DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (a.DATE <= @END OR @END IS NULL)
		AND (a.PERSONAL IN (SELECT ID FROM dbo.TableStringFromXML(@SENDER)) OR @SENDER IS NULL)
		AND (a.NOTE LIKE @NOTE OR @NOTE IS NULL)
		AND (c.StatusID IN (SELECT ID FROM dbo.TableIDFromXML(@STATUS)) OR @STATUS IS NULL)
		AND (a.ID_TYPE IN (SELECT ID FROM dbo.TableGUIDFromXML(@TYPE)) OR @TYPE IS NULL)
		
	ORDER BY DATE DESC, ClientFullName
END
