USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_DETAIL_AVG_INSERT]
	@WEEK_ID					UniqueIdentifier,
	@NET						NVARCHAR(256),
	@COMPL_COUNT				INT,
	@COMPL_NO_ENT				INT,
	@COMPL_WITH_ENT				INT,
	@ENTER_COUNT				INT,
	@USER_COUNT					INT,
	@ZERO_ENTER					INT,
	@ONE_ENTER					INT,
	@TWO_ENTER					INT,
	@THREE_ENTER				INT,
	@AVG_USER_COUNT				FLOAT,
	@AVG_WORK_USER_COUNT		FLOAT,
	@AVG_NWORK_USER_COUNT		FLOAT,
	@AVG_ENTER_COUNT			FLOAT,
	@AVG_WORK_USER_ENTER_COUNT	FLOAT,
	@AVG_SESSION_TIME			FLOAT
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

		INSERT INTO dbo.ClientStatDetailAVG([UpDate],
											WeekId,
											Net,
											ComplCount,
											ComplNoEnt,
											ComplWithEnt,
											EntCount,
											UserCount,
											[0Enter],
											[1Enter],
											[2Enter],
											[3Enter],
											AVGUserCount,
											AVGWorkUserCount,
											AVGNWorkUserCount,
											AVGEntCount,
											AVGWorkUserEntCount,
											AVGSessionTime
											)
		SELECT
				GETDATE(),
				@WEEK_ID,
				@NET,
				@COMPL_COUNT,
				@COMPL_NO_ENT,
				@COMPL_WITH_ENT,
				@ENTER_COUNT,
				@USER_COUNT,
				@ZERO_ENTER,
				@ONE_ENTER,
				@TWO_ENTER,
				@THREE_ENTER,
				@AVG_USER_COUNT,
				@AVG_WORK_USER_COUNT,
				@AVG_NWORK_USER_COUNT,
				@AVG_ENTER_COUNT,
				@AVG_WORK_USER_ENTER_COUNT,
				@AVG_SESSION_TIME;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END;GO
GRANT EXECUTE ON [dbo].[CLIENT_STAT_DETAIL_AVG_INSERT] TO rl_client_stat_detail_avg_i;
GO