USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVER_STAT_SELECT]
	@BEGIN	DATETIME	= NULL,
	@END	DATETIME	= NULL,
	@LOAD	BIT			= NULL,
	@RC		INT			= NULL OUTPUT
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
		    SSD_DATE, SSD_HOSTCOUNT, SSD_QUERY, SSD_SESSIONCOUNT,
		    ROUND(CONVERT(DECIMAL(24, 8), (CONVERT(DECIMAL(24, 8), SSD_TRAFIN) / 1024 / 1024)), 2) AS SSD_TRAFIN,
		    ROUND(CONVERT(DECIMAL(24, 8), (CONVERT(DECIMAL(24, 8), SSD_TRAFOUT) / 1024 / 1024)), 2) AS SSD_TRAFOUT
	    FROM dbo.ServerStatDetail
	    WHERE (SSD_DATE >= @BEGIN OR @BEGIN IS NULL)
		    AND (SSD_DATE <= @END OR @END IS NULL)
		    AND ((SSD_TRAFIN <> 0 OR SSD_TRAFOUT <> 0) OR @LOAD = 0)
	    ORDER BY SSD_DATE DESC
    
	    SET @RC = @@ROWCOUNT

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVER_STAT_SELECT] TO rl_server_stat;
GO
