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
		[Name]				= J.[Name],
		[LastStart]			= J.[Start],
		[AvgLength]			= LN / 1000.0,
		[LastStartDelta]	= dbo.TimeSecToStr(DateDiff(second, J.Start, GetDate())),
		[ExecutonCount]		= CNT
	FROM
	(
		SELECT
			NAME,
			COUNT(*) AS CNT,
			MAX(START) AS START,
			AVG(DateDiff(millisecond, Start, Finish)) AS LN
		FROM Maintenance.Jobs J
		INNER JOIN Maintenance.JobType JT ON J.Type_Id = JT.Id
		WHERE (J.Start >= @Start OR @Start IS NULL)
			AND (J.Start <= @Finish OR @Finish IS NULL)
		GROUP BY NAME
	) AS J
	ORDER BY J.[Name]
END
