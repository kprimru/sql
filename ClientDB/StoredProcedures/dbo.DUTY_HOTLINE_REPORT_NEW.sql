USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DUTY_HOTLINE_REPORT_NEW]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DUTY_HOTLINE_REPORT_NEW]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DUTY_HOTLINE_REPORT_NEW]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME
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
		    [HotlineCount] =
		    (
		        SELECT Count(*)
		        FROM dbo.HotlineChatView a WITH(NOEXPAND)
		        INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DISTR = b.DISTR AND a.COMP = b.COMP
		        INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		        WHERE a.START >= @BEGIN
		            AND a.START <= DateAdd(Day, 1, @END)
		    ),
		    [HotlineAllCount] =
		    (
		        SELECT Count(*)
		        FROM dbo.HotlineChatView a WITH(NOEXPAND)
		        WHERE a.START >= @BEGIN
		            AND a.START <= DateAdd(Day, 1, @END)
		    )

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DUTY_HOTLINE_REPORT_NEW] TO rl_report_client_duty;
GO
