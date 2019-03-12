USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@ST			VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ManagerName, ServiceName, ClientID, CC_ID, ClientFullName, CC_DATE, STT_NAME, CS_NOTE, CC_NOTE, CC_USER
	FROM 
		dbo.ClientSatisfaction
		INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL
		INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
		INNER JOIN dbo.TableGUIDFromXML(@ST) ON ID = STT_ID
		INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = CC_ID_CLIENT 	
	WHERE (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (CC_DATE <= @END OR @END IS NULL)
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
	ORDER BY CC_DATE DESC, ManagerName, ServiceName, ClientFullName, STT_NAME
END