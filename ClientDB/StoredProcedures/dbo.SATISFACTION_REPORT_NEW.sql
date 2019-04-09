USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SATISFACTION_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@MANAGER	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @SERVICE IS NOT NULL
		SET @MANAGER = NULL

	IF OBJECT_ID('tempdb..#satisfaction') IS NOT NULL
		DROP TABLE #satisfaction

	SELECT (
           SELECT dbo.DateOf(MIN(g.CC_DATE))
           FROM dbo.ClientCall g 
           WHERE g.CC_ID_CLIENT = b.ClientID 
				AND dbo.DateOf(g.CC_DATE) BETWEEN @BEGIN AND @END
         ) AS CC_FIRST, ClientFullName, CC_DATE,
         CC_USER, STT_NAME
	
		INTO #satisfaction

	FROM 
		dbo.ClientCall a 
		INNER JOIN dbo.ClientTable b ON a.CC_ID_CLIENT = b.ClientID
		INNER JOIN dbo.ClientSatisfaction c ON CS_ID_CALL = CC_ID
		INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
		INNER JOIN dbo.ServiceTable ON ServiceID = ClientServiceID
	WHERE dbo.DateOf(CC_DATE) BETWEEN @BEGIN AND @END		
		AND (ClientServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND STATUS = 1
	ORDER BY CC_FIRST, ClientFullName, CC_DATE

	SELECT CC_FIRST, ClientFullName, CC_DATE, CC_USER, STT_NAME,
		(
			SELECT COUNT(*)
			FROM #satisfaction b
			WHERE a.ClientFullName = b.ClientFullName
		) AS CallCount
	FROM #satisfaction a
	ORDER BY CC_FIRST, ClientFullName, CC_DATE

	IF OBJECT_ID('tempdb..#satisfaction') IS NOT NULL
		DROP TABLE #satisfaction
END