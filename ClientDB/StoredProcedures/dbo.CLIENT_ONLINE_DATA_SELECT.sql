USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_ONLINE_DATA_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_ONLINE_DATA_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_ONLINE_DATA_SELECT]
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
			b.NAME, LGN, CASE ACTIVITY WHEN 1 THEN 'Да' WHEN 0 THEN 'Нет' ELSE '???' END AS ACTIVITY_DATA,
			ACTIVITY, LOGIN_CNT, dbo.TimeMinToStr(SESSION_TIME) AS SESSION_TIME
		FROM
			dbo.OnlineActivity a
			INNER JOIN Common.Period b ON a.ID_WEEK = b.ID
		WHERE a.ID_HOST = @HOST AND a.DISTR = @DISTR AND a.COMP = @COMP
		ORDER BY b.START DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ONLINE_DATA_SELECT] TO rl_client_online_activity;
GO
