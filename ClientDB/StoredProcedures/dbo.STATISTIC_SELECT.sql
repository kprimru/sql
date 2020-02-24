USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STATISTIC_SELECT]
	@DATE	SMALLDATETIME
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

		SELECT SystemFullName, InfoBankFullName, InfoBankName, Docs
		FROM 
			dbo.StatisticTable a INNER JOIN
			dbo.SystemBanksView b WITH(NOEXPAND) ON a.InfoBankID = b.InfoBankID
		WHERE StatisticDate = @DATE
			AND SystemActive = 1
			AND InfoBankActive = 1
			AND Required IN (1, 2)
		ORDER BY SystemOrder, InfoBankOrder
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END