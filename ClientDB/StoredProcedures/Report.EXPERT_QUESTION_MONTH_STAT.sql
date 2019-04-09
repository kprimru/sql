USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[EXPERT_QUESTION_MONTH_STAT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		NAME AS [Месяц], CNT_RIC AS [Кол-во вопросов], 
		CASE 
			WHEN CNT_RIC_PREV = 0 THEN 0
			ELSE
				ROUND(100 * ((CONVERT(DECIMAL(12, 2), CNT_RIC) - CNT_RIC_PREV) / CNT_RIC_PREV), 2) 
		END AS [Прирост (%)],
		CNT AS [Всего по РИЦ|Кол-во вопросов], 
		CASE 
			WHEN CNT_PREV = 0 THEN 0
			ELSE
				ROUND(100 * ((CONVERT(DECIMAL(12, 2), CNT) - CNT_PREV) / CNT_PREV), 2) 
		END AS [Всего по РИЦ|Прирост (%)]
	FROM
		(
			SELECT 
				NAME, START,
				(
					SELECT COUNT(*)
					FROM dbo.ClientDutyQuestion
					WHERE DATE >= START AND DATE < FINISH
				) AS CNT,
				(
					SELECT COUNT(*)
					FROM dbo.ClientDutyQuestion
					WHERE DATE >= DATEADD(MONTH, -1, START) AND DATE < DATEADD(MONTH, -1, FINISH)
				) AS CNT_PREV,
				(
					SELECT COUNT(*)
					FROM 
						dbo.ClientDutyQuestion a
						INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
						INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
					WHERE DATE >= START AND DATE < FINISH
				) AS CNT_RIC,
				(
					SELECT COUNT(*)
					FROM 
						dbo.ClientDutyQuestion a
						INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP
						INNER JOIN dbo.SystemTable c ON b.HostID = c.HostID AND c.SystemNumber = a.SYS
					WHERE DATE >= DATEADD(MONTH, -1, START) AND DATE < DATEADD(MONTH, -1, FINISH)
				) AS CNT_RIC_PREV
			FROM Common.Period
			WHERE TYPE = 2
				AND FINISH >= '20160420'
				AND START <= GETDATE()
		) AS o_O
	ORDER BY START DESC
END
