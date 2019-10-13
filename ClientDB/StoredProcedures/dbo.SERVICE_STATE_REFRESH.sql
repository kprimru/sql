USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATE_REFRESH]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE SR CURSOR LOCAL FOR 
		SELECT DISTINCT ServiceID
		FROM dbo.ClientView a WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.ServiceStatusId = s.ServiceStatusId;
		
	OPEN SR
	
	DECLARE @SERVICE INT
	
	FETCH NEXT FROM SR INTO @SERVICE
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC dbo.SERVICE_STATE_UPDATE @SERVICE
	
		FETCH NEXT FROM SR INTO @SERVICE
	END
	
	CLOSE SR
	DEALLOCATE SR
END
