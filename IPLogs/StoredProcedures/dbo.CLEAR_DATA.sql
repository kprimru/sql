USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLEAR_DATA]
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

	    DELETE FROM dbo.ServerStatDetail
	    DELETE FROM dbo.ClientStatDetail
	    DELETE FROM dbo.LogFiles
	    DELETE FROM dbo.USRFiles

	    DELETE FROM dbo.ServerStat
	    DELETE FROM dbo.ClientStat
    
	    DELETE FROM dbo.Files
    

	    DBCC CHECKIDENT (ServerStatDetail, RESEED, 1)
	    DBCC CHECKIDENT (ClientStatDetail, RESEED, 1)
	    DBCC CHECKIDENT (LogFiles, RESEED, 1)
	    DBCC CHECKIDENT (USRFiles, RESEED, 1)
	    DBCC CHECKIDENT (ServerStat, RESEED, 1)
	    DBCC CHECKIDENT (ClientStat, RESEED, 1)
	    DBCC CHECKIDENT (Files, RESEED, 1)

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
