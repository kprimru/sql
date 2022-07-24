USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[HOTLINE_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[HOTLINE_SELECT]  AS SELECT 1')
GO

ALTER PROCEDURE [Subhost].[HOTLINE_SELECT]
	@SUBHOST		NVARCHAR(16),
	@START			SMALLDATETIME,
	@FINISH			SMALLDATETIME,
	@CHAT_CNT		INT	= NULL OUTPUT,
	@CHAT_DISTINCT	INT	= NULL OUTPUT
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
			a.START, c.Comment, c.DistrStr, a.FIO, CONVERT(NVARCHAR(256), LEFT(a.CHAT, 255)) AS CHAT, a.CHAT AS CHAT_FULL, a.EMAIL, a.PHONE,
			a.PROFILE, a.RIC_PERSONAL, a.LGN
		FROM
			dbo.HotlineChat a
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
		WHERE c.SubhostName = @SUBHOST
			AND (a.START >= @START OR @START IS NULL)
			AND (a.START < @FINISH OR @FINISH IS NULL)
		ORDER BY a.START DESC

		SELECT @CHAT_CNT = @@ROWCOUNT

		SELECT @CHAT_DISTINCT = COUNT(*)
		FROM
			(
				SELECT DISTINCT b.HostID, a.DISTR, a.COMP
				FROM
					dbo.HotlineChat a
					INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
					INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
				WHERE c.SubhostName = @SUBHOST
					AND (a.START >= @START OR @START IS NULL)
					AND (a.START < @FINISH OR @FINISH IS NULL)
			) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[HOTLINE_SELECT] TO rl_web_subhost;
GO
