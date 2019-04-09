USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[JOB_SELECT]
	@Start	DateTime = NULL,
	@Finish	DateTime = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[ID]				= J.[ID],
		[Name]				= J.[Name],
		[LastStart]			= J.[Start],
		[LastFinish]		= J.[Finish],
		[AvgLength]			= LN / 1000.0,
		[LastStartDelta]	= dbo.TimeSecToStr(DateDiff(second, J.Start, GetDate())),
		[LastStartDeltaSec]	= DATEDIFF(second, J.Start, GETDATE()),
		[MaxDeltaSec]		= J.[Expire],
		[ExecutonCount]		= CNT
	FROM
	(
		SELECT
			MAX(J.Type_Id) AS ID,
			NAME,
			COUNT(*) AS CNT,
			MAX(START) AS START,
			MAX(FINISH) AS FINISH,
			AVG(DateDiff(millisecond, Start, Finish)) AS LN,
			MAX(JT.ExpireTime) AS EXPIRE
		FROM Maintenance.Jobs J
		INNER JOIN Maintenance.JobType JT ON J.Type_Id = JT.Id
		WHERE (J.Start >= @Start OR @Start IS NULL)
			AND (J.Start <= @Finish OR @Finish IS NULL)
		GROUP BY NAME
	) AS J
	ORDER BY J.[Name]
END
