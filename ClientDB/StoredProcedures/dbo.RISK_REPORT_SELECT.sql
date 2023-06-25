USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_REPORT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_REPORT_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[RISK_REPORT_SELECT]
	@Client_Id	Int,
	@Complect	VarChar(100),
	@DateFrom	SmallDateTime = NULL,
	@DateTo		SmallDateTime = NULL
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
			[Обращений в ДС]		= Sum(D.[DutyCount]),
			[ЗВЭ]					= Sum(D.[DutyQuestionCount]),
			[Чаты]					= Sum(D.[DutyHotlineCount]),
			[Конкуренты]			= Sum(D.[RivalCount]),
			[Обучение]				= Sum(D.[StudyCount]),
			[Семинары]				= Sum(D.[SeminarCount]),
			[Пополнений]			= Sum(D.[UpdatesCount]),
			[Пополнений пропущено]	= Sum(D.[LostCount]),
			[Скачанных документов]	= Avg(D.[DownloadCount]),
			[Онлайн-активность]		= Sum(D.[OnlineActivityCount]),
			[Оффлайн-входов]		= Sum(D.[OfflineEnterCount]),
			[Подписки]				= Avg(D.[DeliveryCount]),
			[DateTime]				= R.[DateTime],
			[Report_Id]				= D.[Report_Id]
		FROM [dbo].[RiskReportDetail]				AS D
		INNER JOIN [ClientDB].[dbo].[RiskReport]	AS R ON R.[Id] = D.[Report_Id]
		WHERE D.[ClientID] = @Client_Id
			AND (D.[Complect] = @Complect OR @Complect IS NULL)
			AND (R.[DateTime] >= @DateFrom OR @DateFrom IS NULL)
			AND (R.[DateTime] <= @DateTo OR @DateTo IS NULL)
		GROUP BY R.[DateTime], D.[Report_Id]
		ORDER BY R.[DateTime]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[RISK_REPORT_SELECT] TO rl_risk;
GO
