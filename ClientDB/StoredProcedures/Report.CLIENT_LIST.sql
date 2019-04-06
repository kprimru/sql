USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CLIENT_LIST]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		b.ManagerName AS [���-��], b.ServiceName AS [��], a.ClientFullName AS [������], 
		USR_CHECK AS [����� USR], STT_CHECK AS [����� STT], HST_CHECK AS [����� HST], INET_CHECK AS [��� ���������]
	FROM 
		dbo.ClientTable a
		INNER JOIN dbo.ClientView b ON a.ClientID = b.ClientID
	WHERE STATUS = 1
		AND StatusID = 2
		AND
			(
				HST_CHECK = 0
				OR 
				STT_CHECK = 0
				OR
				USR_CHECK = 0
				OR
				INET_CHECK = 1
			)
	ORDER BY ManagerName, ServiceName, b.ClientFullName
END
