USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_RECALCULATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_RECALCULATE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[RISK_RECALCULATE]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Report_Id		Integer,
		@DateFrom		SmallDateTime,
		@DateTo			SmallDateTime;

	DECLARE @Result Table
	(
		[RN]						SmallInt,
		[ClientID]					Int,
		[ClientFullName]			VarChar(512),
		[ServiceTypeShortName]		VarChar(64),
		[ServiceName]				VarChar(256),
		[ManagerName]				VarChar(256),
		[Distrs]					VarChar(Max),
		[Complect]					VarChar(128),
		[DutyCount]					SmallInt,
		[DutyQuestionCount]			SmallInt,
		[DutyHotlineCount]			SmallInt,
		[RivalCount]				SmallInt,
		[StudyCount]				SmallInt,
		[SeminarCount]				SmallInt,
		[UpdatesCount]				SmallInt,
		[LostCount]					SmallInt,
		[DownloadCount]				SmallInt,
		[DownloadBases]				VarChar(512),
		[OnlineActivityCount]		SmallInt,
		[OfflineEnterCount]			SmallInt,
		[OldRes]					VarChar(128),
		[OldConsExe]				VarChar(128),
		[ComplianceIB]				VarChar(512),
		[DeliveryCount]				SmallInt,
		[OldEvent]					SmallDateTime,
		[LastPay]					VarChar(64)
	);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @DateFrom = DateAdd(Month, -3, dbo.DateOf(GetDate()));
		SET @DateTo = dbo.DateOf(GetDate());

		INSERT INTO @Result
		EXEC [dbo].[RISK_REPORT2]
			@Managers_IDs		= NULL,
			@Services_IDs		= NULL,
			@ClientTypes_IDs	= NULL,
			@ClientName			= NULL,
			@Distr				= NULL,
			@Systems_IDs		= NULL,
			@NetTypes_IDs		= NULL,
			@DateFrom			= @DateFrom,
			@DateTo				= @DateTo;

		INSERT INTO [dbo].[RiskReport]([DateTime])
		SELECT GetDate();

		SELECT @Report_Id = Scope_Identity();

		INSERT INTO [dbo].[RiskReportDetail]
		(
			[Report_Id],
			[RN],
			[ClientID],
			[ClientFullName],
			[ServiceTypeShortName],
			[ServiceName],
			[ManagerName],
			[Distrs],
			[Complect],
			[DutyCount],
			[DutyQuestionCount],
			[DutyHotlineCount],
			[RivalCount],
			[StudyCount],
			[SeminarCount],
			[UpdatesCount],
			[LostCount],
			[DownloadCount],
			[DownloadBases],
			[OnlineActivityCount],
			[OfflineEnterCount],
			[OldRes],
			[OldConsExe],
			[ComplianceIB],
			[DeliveryCount],
			[OldEvent],
			[LastPay]
		)
		SELECT
			@Report_Id,
			[RN],
			[ClientID],
			[ClientFullName],
			[ServiceTypeShortName],
			[ServiceName],
			[ManagerName],
			[Distrs],
			[Complect],
			IsNull([DutyCount], 0),
			IsNull([DutyQuestionCount], 0),
			IsNull([DutyHotlineCount], 0),
			IsNull([RivalCount], 0),
			IsNull([StudyCount], 0),
			IsNull([SeminarCount], 0),
			IsNull([UpdatesCount], 0),
			IsNull([LostCount], 0),
			IsNull([DownloadCount], 0),
			[DownloadBases],
			IsNull([OnlineActivityCount], 0),
			IsNull([OfflineEnterCount], 0),
			[OldRes],
			[OldConsExe],
			[ComplianceIB],
			IsNull([DeliveryCount], 0),
			[OldEvent],
			[LastPay]
		FROM @Result;

		EXEC [dbo].[RISK_REPORT_NOTIFY]
			@Report_Id = @Report_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
