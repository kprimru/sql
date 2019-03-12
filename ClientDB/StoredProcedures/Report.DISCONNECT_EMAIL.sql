USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[DISCONNECT_EMAIL]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT 
		b.ClientFullName AS [Клиент], b.ServiceStatusName AS [Статус], a.ClientEMail AS [Email],
		(
			SELECT TOP 1 DisconnectDate
			FROM dbo.ClientDisconnectView z WITH(NOEXPAND)
			WHERE z.ClientID = b.ClientID
			ORDER BY DisconnectDate DESC
		) AS [Дата отключения]
	FROM 
		dbo.ClientEMailView a
		INNER JOIN dbo.ClientView b ON a.ClientID = b.ClientID
	WHERE ServiceStatusID <> 2
	ORDER BY ClientFullName
END
