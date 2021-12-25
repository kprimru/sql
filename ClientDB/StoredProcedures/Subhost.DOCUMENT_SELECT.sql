USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[DOCUMENT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[DOCUMENT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[DOCUMENT_SELECT]
	@SUBHOST	NVARCHAR(16),
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME
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

		SET @FINISH = DATEADD(DAY, 1, @FINISH)

		SELECT
			a.DATE, c.Comment, c.DistrStr, a.IB, a.IB_NUM, a.DOC_NAME
		FROM
			dbo.ControlDocument a
			INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
		WHERE c.SubhostName = @SUBHOST
			AND (a.DATE >= @START OR @START IS NULL)
			AND (a.DATE < @FINISH OR @FINISH IS NULL)
		ORDER BY a.DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[DOCUMENT_SELECT] TO rl_web_subhost;
GO
