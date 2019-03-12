USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[DUTY_DIRECTION_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@DUTY		INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		NAME, 
		(	
			SELECT COUNT(*) 
			FROM 
				dbo.ClientDutyTable b 
				INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
			WHERE a.ID = b.ID_DIRECTION
				AND (b.DutyID = @DUTY OR @DUTY IS NULL)
				AND b.STATUS = 1 
				AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
				AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
				AND c.STATUS = 1
		) AS CallCount,
		(
			SELECT SUM(ClientDutyDocs) 
			FROM 
				dbo.ClientDutyTable b 				
				INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
			WHERE a.ID = b.ID_DIRECTION
				AND (b.DutyID = @DUTY OR @DUTY IS NULL)
				AND b.STATUS = 1
				AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
				AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
				AND c.STATUS = 1
		) AS DocCount
	FROM 
		dbo.CallDirection a
	WHERE EXISTS
		(
			SELECT *
			FROM 
				dbo.ClientDutyTable b 
				INNER JOIN dbo.ClientTable c ON b.ClientID = c.ClientID
			WHERE a.ID = b.ID_DIRECTION
				AND (b.DutyID = @DUTY OR @DUTY IS NULL)
				AND b.STATUS = 1
				AND dbo.DateOf(b.ClientDutyDateTime) BETWEEN @BEGIN AND @END
				AND (c.ClientServiceID = @SERVICE OR @SERVICE IS NULL)
				AND c.STATUS = 1
		)
END
