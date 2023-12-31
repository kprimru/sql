USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_SELECT]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		DECLARE @RC INT

		SET @END = DATEADD(DAY, 1, GETDATE())

		SELECT @RC = COUNT(*)
		FROM
			(
				SELECT a.FL_NAME, MAX(DATE) AS DATE
				FROM
					(
						SELECT DISTINCT FL_NAME
						FROM dbo.ClientStat
					) AS a
					INNER JOIN dbo.ClientStat b ON a.FL_NAME = b.FL_NAME
				WHERE b.DATE >= @BEGIN AND b.DATE < @END
				GROUP BY a.FL_NAME
			) AS o_O

		SELECT y.FL_NAME, y.FL_DATE, y.FL_DATA, @RC AS RC
		FROM
			(
				SELECT a.FL_NAME, MAX(DATE) AS DATE
				FROM
					(
						SELECT DISTINCT FL_NAME
						FROM dbo.ClientStat
					) AS a
					INNER JOIN dbo.ClientStat b ON a.FL_NAME = b.FL_NAME
				WHERE b.DATE >= @BEGIN AND b.DATE < @END
				GROUP BY a.FL_NAME
			) AS z
			INNER JOIN dbo.ClientStat y ON z.FL_NAME = y.FL_NAME AND z.DATE = y.DATE
		ORDER BY FL_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH


END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STAT_SELECT] TO rl_client_stat_save;
GO
