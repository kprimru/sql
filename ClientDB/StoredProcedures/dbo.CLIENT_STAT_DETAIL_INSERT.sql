USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_STAT_DETAIL_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_STAT_DETAIL_INSERT]  AS SELECT 1')
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
	@WEEK_ID		UniqueIdentifier,
	@ENTER_DELTA			VarChar(100),
	@BUSY_SESSION_COUNT		VarChar(100),
	@FREE_SPACE_RATE		VarChar(100),
	@FREE_SPACE_REQUIRED	VarChar(100),
	@FREE_SPACE_AVAILABLE	VarChar(100)
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

		UPDATE dbo.ClientStatDetail SET
			Net					= @NET,
			UserCount			= @USER_COUNT,
			EnterSum			= @ENTER_SUM,
			[0Enter]			= @ZERO_ENTER,
			[1Enter]			= @ONE_ENTER,
			[2Enter]			= @TWO_ENTER,
			[3Enter]			= @THREE_ENTER,
			SessionTimeSum		= @SES_TIME_SUM,
			SessionTimeAVG		= @SES_TIME_AVG,
			EnterDelta			= @ENTER_DELTA,
			BusySessionCount	= @BUSY_SESSION_COUNT,
			FreeSpaceRate		= @FREE_SPACE_RATE,
			FreeSpaceRequired	= @FREE_SPACE_REQUIRED,
			FreeSpaceAvailable	= @FREE_SPACE_AVAILABLE
		WHERE WeekId = @WEEK_ID
			AND HostId = 1
			AND Distr = @DISTR
			AND Comp = @COMP;


		IF @@RowCount = 0
			INSERT INTO dbo.ClientStatDetail (
				[UpDate], WeekId, HostId, Distr, Comp, Net, UserCount, EnterSum, [0Enter], [1Enter], [2Enter], [3Enter], SessionTimeSum, SessionTimeAVG,
				EnterDelta, BusySessionCount, FreeSpaceRate, FreeSpaceRequired, FreeSpaceAvailable
				)
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
				@SES_TIME_AVG,
				@ENTER_DELTA,
				@BUSY_SESSION_COUNT,
				@FREE_SPACE_RATE,
				@FREE_SPACE_REQUIRED,
				@FREE_SPACE_AVAILABLE;

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
