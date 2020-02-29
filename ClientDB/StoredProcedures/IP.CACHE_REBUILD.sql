USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IP].[CACHE_REBUILD]
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

		TRUNCATE TABLE IP.ConsErr

		INSERT INTO IP.ConsErr
		SELECT UF_SYS, UF_DISTR, UF_COMP, MAX(UF_DATE)
		FROM [PC275-SQL\OMEGA].IPLogs.dbo.USRFiles b
		INNER JOIN [PC275-SQL\OMEGA].IPLogs.dbo.ConsErr a ON b.UF_ID = a.ID_USR
		GROUP BY UF_DISTR, UF_COMP, UF_SYS
		
		TRUNCATE TABLE IP.LogLast
		
		INSERT INTO IP.LogLast
		SELECT LF_SYS, LF_DISTR, LF_COMP, MAX(LF_DATE)
		FROM [PC275-SQL\OMEGA].[IPLogs].dbo.LogFiles
		GROUP BY LF_SYS, LF_DISTR, LF_COMP
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
