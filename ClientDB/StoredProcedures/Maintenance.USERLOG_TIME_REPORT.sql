USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Maintenance].[USERLOG_TIME_REPORT]
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@USR	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT USR, S_DAY, WORK_TIME, dbo.TimeMinToStr(WORK_TIME) AS WORK_TIME_STR
	FROM
		(
			SELECT USR, S_DAY, SUM(WORK_TIME) AS WORK_TIME
			FROM Maintenance.UserlogSessionView
			WHERE (S_DAY >= @START OR @START IS NULL)
				AND (S_DAY <= @FINISH OR @FINISH IS NULL)
				AND (USR IN (SELECT ID FROM dbo.TableStringNewFromXML(@USR)) OR @USR IS NULL)
			GROUP BY USR, S_DAY
		) AS a
	ORDER BY S_DAY DESC, WORK_TIME DESC
END
