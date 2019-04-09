USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_JOURNAL_REPORT]
	@YEAR	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DP	INT
	
	SELECT @DP = DATEPART(YEAR, START)
	FROM Common.Period
	WHERE ID = @YEAR
	
	SELECT 
		ROW_NUMBER() OVER(ORDER BY ClientFullName, a.START) AS RN,
		ClientFullName,
		CASE
			WHEN b.ID IS NULL THEN '� ' + CONVERT(VARCHAR(20), a.START, 104) + ' �� ' + CONVERT(VARCHAR(20), a.FINISH, 104)
			ELSE b.NAME
		END AS PERIOD
	FROM 
		dbo.ClientJournal a
		INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
		INNER JOIN dbo.Journal c ON c.ID = a.ID_JOURNAL
		LEFT OUTER JOIN Common.Period b ON a.START = b.START AND a.FINISH = b.FINISH
	WHERE a.STATUS = 1 
		AND DATEPART(YEAR, a.START) = @DP
		AND c.DEF = 1
	ORDER BY ClientFullName, a.START
END
