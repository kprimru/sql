USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[DATABASE_CLEAR (AUTO)]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ToDay SmallDateTime;

	SET @ToDay = dbo.DateOf(GetDate());
		
	-- файлы СТТ
	DELETE
	FROM dbo.ClientStat
	WHERE DATE < DateAdd(MONTH, -7, @ToDay);
	
	-- файлы СТТ от подхостов
	DELETE
	FROM Subhost.SttFiles
	WHERE DATE < DateAdd(MONTH, -7, @ToDay);
	
	-- пригласительные на семинар
	DELETE
	FROM Seminar.Invite
	WHERE DATE < DateAdd(MONTH, -7, @ToDay);
	
	-- журнал выполнения заданий
	DELETE
	FROM Maintenance.Jobs
	WHERE START < DateAdd(MONTH, -1, @ToDay);
	
	-- донесушки
	DELETE
	FROM dbo.ServiceReportClient
	WHERE SRC_ID_SR IN
		(
			SELECT SR_ID
			FROM dbo.ServiceReport
			WHERE SR_DATE < DateAdd(Month, -7, @ToDay)
		);
	
	DELETE
	FROM dbo.ServiceReportDistr
	WHERE SRD_ID_SR IN
		(
			SELECT SR_ID
			FROM dbo.ServiceReport
			WHERE SR_DATE < DateAdd(Month, -7, @ToDay)
		);
	
	DELETE
	FROM dbo.ServiceReport
	WHERE SR_DATE < DateAdd(Month, -7, @ToDay)
	
	--сводка по участкам СИ
	DELETE
	FROM dbo.ServiceStateDetail
	WHERE ID_STATE IN
		(
			SELECT ID
			FROM dbo.ServiceState
			WHERE DATE < DateAdd(Month, -3, @ToDay)
		)
	
	DELETE
	FROM dbo.ServiceState
	WHERE DATE < DateAdd(Month, -3, @ToDay)
END
