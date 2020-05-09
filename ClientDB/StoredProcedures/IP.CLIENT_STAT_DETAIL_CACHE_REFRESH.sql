USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [IP].[CLIENT_STAT_DETAIL_CACHE_REFRESH]
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

		TRUNCATE TABLE IP.ClientStatDetailCache

		INSERT INTO
			IP.ClientStatDetailCache(CSD_SYS, CSD_DISTR, CSD_COMP, CSD_START, CSD_CODE_CLIENT, CSD_CODE_CLIENT_NOTE, CSD_USR)
		SELECT
			CSD_SYS,
			CSD_DISTR,
			CSD_COMP,
			CSD_START,
			CSD_CODE_CLIENT,
			CSD_CODE_CLIENT_NOTE,
			CSD_USR
		FROM
			(
				SELECT
					ROW_NUMBER() OVER(PARTITION BY CSD_SYS, CSD_DISTR, CSD_COMP ORDER BY CSD_START DESC) AS [rn],
					CSD_SYS,
					CSD_DISTR,
					CSD_COMP,
					CSD_START,
					CSD_CODE_CLIENT,
					ISNULL((SELECT TOP 1 RC_TEXT
						 FROM dbo.IPReturnCodeView
						 WHERE RC_NUM = a.CSD_CODE_CLIENT
								AND RC_TYPE = 'CLIENT'
		 				 ORDER BY RC_ID
					), 'неизвестный код') as CSD_CODE_CLIENT_NOTE,
					CSD_USR
				FROM
					dbo.IPClientDetailView a
			) z
		WHERE
			rn=1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END;GO
