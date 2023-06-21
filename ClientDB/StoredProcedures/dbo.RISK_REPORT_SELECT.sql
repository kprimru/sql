USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RISK_REPORT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[RISK_REPORT_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [dbo].[RISK_REPORT_SELECT]
	@CLIENTID	INT,
	@START		SMALLDATETIME = NULL,
	@END		SMALLDATETIME = NULL
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

		SELECT	 A.[DutyCount] --AS ''
				,A.[DutyQuestionCount] --AS ''
				,A.[DutyHotlineCount] --AS ''
				,A.[RivalCount] --AS ''
				,A.[StudyCount] --AS ''
				,A.[SeminarCount] --AS ''
				,A.[UpdatesCount] --AS ''
				,A.[LostCount] --AS ''
				,A.[DownloadCount] --AS ''
				,A.[OnlineActivityCount] --AS ''
				,A.[OfflineEnterCount]-- AS ''
				,A.[DeliveryCount] --AS ''
				,B.[DateTime]
				,A.[Report_Id]
		FROM [dbo].[RiskReportDetail] A
		INNER JOIN [ClientDB].[dbo].[RiskReport] B ON B.Id = A.Report_Id
		WHERE ClientID = @CLIENTID
			AND COALESCE(@START, B.[DateTime]) <= B.[DateTime]
			AND COALESCE(@END, B.[DateTime]) >= B.[DateTime]
		ORDER BY A.[Report_Id]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
