USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_STAT_DETAIL_COMPLECT_SELECT]
	@CLIENT	INT
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

		SELECT DistrStr + ' (' + DistrTypeName + ')' AS DIS_STR, HostID, DISTR, COMP
		FROM
			dbo.ClientDistrView a WITH(NOEXPAND)
		WHERE ID_CLIENT = @CLIENT
			AND EXISTS
				(
					SELECT *
					FROM dbo.ClientStatDetail z
					WHERE a.HostID = z.HostID
						AND a.DISTR = z.DISTR
						AND a.COMP = z.COMP
				)
		ORDER BY SystemOrder, DISTR, COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_STAT_DETAIL_COMPLECT_SELECT] TO rl_client_stat_detail_r;
GO