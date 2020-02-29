USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STATISTIC_GET]
	@DATE		SMALLDATETIME,
	@SYSTEM_ID	INT	
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
			a.[InfoBankID], a.[InfoBankName], a.[InfoBankFullName],
			(
				SELECT TOP 1 b.DOCS
				FROM dbo.StatisticTable b 
				WHERE	b.InfoBankID = a.InfoBankID
					AND b.StatisticDate <= @DATE
				ORDER BY StatisticDate DESC
			) as DOCS
		FROM [dbo].[SystemBanksView] a
		WHERE a.SystemID = @SYSTEM_ID
		ORDER BY a.InfoBankOrder
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
