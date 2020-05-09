USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_DETAIL_INSERT]
	@DISTR			INT,
	@COMP			INT,
	@NET			NVARCHAR(256),
	@USER_COUNT		INT,
	@ENTER_SUM		INT,
	@ZERO_ENTER		INT,
	@ONE_ENTER		INT,
	@TWO_ENTER		INT,
	@THREE_ENTER	INT,
	@SES_TIME_SUM	INT,
	@SES_TIME_AVG	FLOAT,
	@WEEK_ID		UniqueIdentifier
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

		INSERT INTO dbo.ClientStatDetail ([UpDate], WeekId, HostId, Distr, Comp, Net, UserCount, EnterSum, [0Enter], [1Enter], [2Enter], [3Enter], SessionTimeSum, SessionTimeAVG)
		SELECT
			GETDATE(),
			@WEEK_ID,
			1,
			@DISTR,
			@COMP,
			@NET,
			@USER_COUNT,
			@ENTER_SUM,
			@ZERO_ENTER,
			@ONE_ENTER,
			@TWO_ENTER,
			@THREE_ENTER,
			@SES_TIME_SUM,
			@SES_TIME_AVG

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END;GO
GRANT EXECUTE ON [dbo].[CLIENT_STAT_DETAIL_INSERT] TO rl_client_stat_detail_i;
GO