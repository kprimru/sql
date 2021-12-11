USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[HOTLINE_ALIEN]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[HOTLINE_ALIEN]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[HOTLINE_ALIEN]
	@PARAM	NVARCHAR(MAX) = NULL
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

		SELECT SubhostName, Comment, DistrStr, FIRST_DATE, FIO, EMAIL, PHONE, CHAT, LGN, RIC_PERSONAL
		FROM
			dbo.HotlineChat a
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber AND SystemRic = 20
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON b.HostID = c.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
		WHERE RIC_PERSONAL <> ''
			AND CHAT LIKE '%] РИЦ (%'
			AND
			(
				c.SubhostName = 'Н1' AND RIC_PERSONAL NOT LIKE '%Находка%'
				OR
				c.SubhostName = 'У1' AND RIC_PERSONAL NOT LIKE '%Уссурийск%'
				OR
				--c.SubhostName = 'Л1' AND RIC_PERSONAL NOT LIKE '%Славянка%'
				--OR
				c.SubhostName = 'М' AND RIC_PERSONAL NOT LIKE '%Артем%'
			)
		ORDER BY FIRST_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[HOTLINE_ALIEN] TO rl_report;
GO
