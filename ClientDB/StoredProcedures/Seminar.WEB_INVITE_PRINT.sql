USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Seminar].[WEB_INVITE_PRINT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
		SET @ID = '5B2A1FC1-3423-E711-A24F-0007E92AAFC5'
	
	UPDATE Seminar.Personal
	SET INVITE_NUM = ISNULL((SELECT MAX(INVITE_NUM) + 1 FROM Seminar.Personal WHERE STATUS = 1), 1)
	WHERE ID = @ID
	
	SELECT 
		a.ID
		PSEDO, c.NAME AS SEMINAR, 
		--CONVERT(NVARCHAR(64), b.DATE, 104) AS DATE,
		CONVERT(NVARCHAR(8), DATEPART(DAY, b.DATE)) + ' ' + DATENAME(MONTH, b.DATE) + ' ' + CONVERT(VARCHAR(8), DATEPART(YEAR, b.DATE)) + ' (' + DATENAME(WEEKDAY, b.DATE) + ')' AS DATE,
		LEFT(CONVERT(NVARCHAR(64), b.TIME, 108), 5) AS START,
		INVITE_NUM,
		READER AS LECTOR,
		c.NOTE AS SEMINAR_QUEST,
		'��� "�����"' AS PLACE
	FROM 
		Seminar.Personal a
		INNER JOIN Seminar.Schedule b ON a.ID_SCHEDULE = b.ID
		INNER JOIN Seminar.Subject c ON b.ID_SUBJECT = c.ID
	WHERE a.ID = @ID
END
