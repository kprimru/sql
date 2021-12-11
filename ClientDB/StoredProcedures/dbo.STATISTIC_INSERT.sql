USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STATISTIC_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STATISTIC_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STATISTIC_INSERT]
	@IB_ID	INT,
	@DATE	SMALLDATETIME,
	@DOC	INT
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

		UPDATE dbo.StatisticTable
		SET Docs = @DOC
		WHERE InfoBankID = @IB_ID
			AND StatisticDate = @DATE

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.StatisticTable(InfoBankID, StatisticDate, Docs)
			VALUES (@IB_ID, @DATE, @DOC)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STATISTIC_INSERT] TO DBStatistic;
GO
