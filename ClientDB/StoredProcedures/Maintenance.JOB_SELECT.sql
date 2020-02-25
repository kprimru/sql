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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT
			[ID]				= J.[ID],
			[Name]				= JT.[Name],
			[LastStart]			= J.[Start],
			[LastFinish]		= J.[Finish],
			[AvgLength]			= LN / 1000.0,
			[LastStartDelta]	= dbo.TimeSecToStr(DateDiff(second, J.Start, GetDate())),
			[LastStartDeltaSec]	= DATEDIFF(second, J.Start, GETDATE()),
			[MaxDeltaSec]		= JT.[ExpireTime],
			[ExecutonCount]		= CNT,
			[Error]				=	(
										SELECT TOP (1) ERR
										FROM Maintenance.Jobs MJ
										WHERE J.ID = MJ.ID
										ORDER BY MJ.START DESC
									)
		FROM
		(
			SELECT
				J.Type_Id AS ID,
				COUNT(*) AS CNT,
				MAX(START) AS START,
				MAX(FINISH) AS FINISH,
				AVG(DateDiff(millisecond, Start, Finish)) AS LN
			FROM Maintenance.Jobs J
			WHERE (J.Start >= @Start OR @Start IS NULL)
				AND (J.Start <= @Finish OR @Finish IS NULL)
			GROUP BY J.[Type_Id]
		) AS J
		INNER JOIN Maintenance.JobType JT ON J.ID = JT.Id
		ORDER BY JT.[Name]
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
