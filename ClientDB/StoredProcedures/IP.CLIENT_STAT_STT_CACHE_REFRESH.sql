USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IP].[CLIENT_STAT_STT_CACHE_REFRESH]
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
	
		TRUNCATE TABLE IP.ClientStatSTTCache

		INSERT INTO
			IP.ClientStatSTTCache(CSD_SYS, CSD_DISTR, CSD_COMP, CSD_START, CSD_END)
		SELECT DISTINCT
			CSD_SYS, 
			CSD_DISTR, 
			CSD_COMP, 
			CSD_START, 
			CSD_END
		FROM [PC275-SQL\OMEGA].[IPLogs].[dbo].[ClientStatDetail]
		WHERE CSD_START IS NOT NULL
			AND CSD_STT_SEND = 1 
			AND CSD_STT_RESULT = 1
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END;