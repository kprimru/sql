USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[STAT_SELECT]
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

		SELECT DISTINCT CONVERT(VARCHAR(20), StatisticDate, 112) AS StatisticDate, SystemBaseName, InfoBankName, Docs
		FROM
			dbo.StatisticTable a
			INNER JOIN dbo.InfoBankTable b ON a.InfoBankID = b.InfoBankID
			INNER JOIN dbo.SystemBankTable c ON c.InfoBankID = b.InfoBankID
			INNER JOIN dbo.SystemTable d ON d.SystemID = c.SystemID
		WHERE StatisticDate >= dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STAT_SELECT] TO rl_stat_export;
GRANT EXECUTE ON [dbo].[STAT_SELECT] TO rl_stat_import;
GO
