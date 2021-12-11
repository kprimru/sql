USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[IP].[LIST_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [IP].[LIST_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [IP].[LIST_SELECT]
	@TP		TINYINT,
	@DISTR	INT,
	@NAME	NVARCHAR(256),
	@STATUS	TINYINT
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
			a.ID, ID_HOST, DISTR, COMP, SET_DATE, SET_USER, SET_REASON, UNSET_DATE, UNSET_USER, UNSET_REASON,
			b.DS_INDEX, b.DistrStr, b.Comment
		FROM
			IP.Lists a
			INNER JOIN  Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.ID_HOST = b.HostID AND a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
		WHERE TP = @TP
			AND (DISTR = @DISTR OR @DISTR IS NULL)
			AND (@STATUS IS NULL OR @STATUS = 0 OR @STATUS = 1 AND UNSET_DATE IS NULL OR @STATUS = 2 AND UNSET_DATE IS NOT NULL)
			AND (b.Comment LIKE @NAME OR @NAME IS NULL)
		ORDER BY b.SystemOrder, b.DistrNumber, b.CompNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [IP].[LIST_SELECT] TO rl_ip_list;
GO
