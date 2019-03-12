USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_MESSAGE_NOTIFY]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TOP 100
		ID, ClientFullName, ID_CLIENT,
		ClientFullName + ' ' + CONVERT(VARCHAR(20), DATE, 104) + ' ' + NOTE AS NOTE
	FROM 
		dbo.ClientMessage a
		INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
	WHERE RECEIVE_USER = ORIGINAL_LOGIN()
		AND a.STATUS = 1
		AND HIDE = 0
	ORDER BY UPD_DATE DESC
END
