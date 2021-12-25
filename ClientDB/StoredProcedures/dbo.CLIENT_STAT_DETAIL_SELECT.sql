USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_STAT_DETAIL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_STAT_DETAIL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_DETAIL_SELECT]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT
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
			P.NAME,
			[UpDate],
			Net,
			UserCount,
			EnterSum,
			[0Enter],
			[1Enter],
			[2Enter],
			[3Enter],
			SessionTimeSum = dbo.TimeMinToStr(SessionTimeSum),
			SessionTimeAVG = dbo.TimeSecToStr(Floor(SessionTimeAVG * 60))
		FROM dbo.ClientStatDetail D
		INNER JOIN Common.Period P ON D.WeekId = P.Id
		WHERE	HostId = @HOST
			AND Distr = @DISTR
			AND Comp = @COMP
		ORDER BY P.START DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STAT_DETAIL_SELECT] TO rl_client_stat_detail_r;
GO
