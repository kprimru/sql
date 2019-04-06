USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SATISFACTION_STAT_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	SELECT 
		ServiceName,
		(	
			SELECT COUNT(*)
			FROM
				dbo.ClientTable				
			WHERE ServiceID = ClientServiceID				
				AND StatusID = 2
				AND STATUS = 1
		) AS ClientCount,
		(
			SELECT COUNT(*)
			FROM
				dbo.ClientCall
				INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
				INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
			WHERE ServiceID = ClientServiceID
				AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
				AND STATUS = 1
		) AS CallCount,
		(
			SELECT COUNT(*)
			FROM
				dbo.ClientCall
				INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
				INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
				INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
			WHERE ServiceID = ClientServiceID
				AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
				AND STT_RESULT = 1
				AND STATUS = 1
		) AS SatCount,
		(
			SELECT COUNT(*)
			FROM
				dbo.ClientCall
				INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
				INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
				INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
			WHERE ServiceID = ClientServiceID
				AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
				AND STT_RESULT = 0
				AND STATUS = 1
		) AS UnSatCount
	FROM dbo.ServiceTable a
	WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND EXISTS
		(
			SELECT *
			FROM
				dbo.ClientCall
				INNER JOIN dbo.ClientTable ON CC_ID_CLIENT = ClientID
				INNER JOIN dbo.ClientSatisfaction ON CS_ID_CALL = CC_ID
			WHERE ServiceID = ClientServiceID
				AND dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END
				AND STATUS = 1
		)
	ORDER BY ServiceName
END