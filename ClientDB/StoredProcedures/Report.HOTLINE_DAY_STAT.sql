USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[HOTLINE_DAY_STAT]
	@PARAM	NVARCHAR(MAX)
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
			CONVERT(NVARCHAR(32), DATE_S, 104) + ' (' + DATENAME(WEEKDAY, DATE_S) + ')' AS [День],
			(
				SELECT COUNT(*)
				FROM
					dbo.HotlineChatView a WITH(NOEXPAND)
					--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
				WHERE a.DATE_S = z.DATE_S
					AND b.SubhostName = ''
			) AS [Базис],
			(
				SELECT COUNT(*)
				FROM
					dbo.HotlineChatView a WITH(NOEXPAND)
					--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
				WHERE a.DATE_S = z.DATE_S
					AND b.SubhostName = 'Н1'
			) AS [Подхост|Находка],
			(
				SELECT COUNT(*)
				FROM
					dbo.HotlineChatView a WITH(NOEXPAND)
					--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
				WHERE a.DATE_S = z.DATE_S
					AND b.SubhostName = 'У1'
			) AS [Подхост|Уссурийск],
			(
				SELECT COUNT(*)
				FROM
					dbo.HotlineChatView a WITH(NOEXPAND)
					--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
				WHERE a.DATE_S = z.DATE_S
					AND b.SubhostName = 'М'
			) AS [Подхост|Артем],
			(
				SELECT COUNT(*)
				FROM
					dbo.HotlineChatView a WITH(NOEXPAND)
					--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
				WHERE a.DATE_S = z.DATE_S
					AND b.SubhostName = 'Л1'
			) AS [Подхост|Славянка],
			(
				SELECT COUNT(*)
				FROM
					dbo.HotlineChatView a WITH(NOEXPAND)
					--INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
					INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.HostID = b.HostID AND a.COMP = b.CompNumber
				WHERE a.DATE_S = z.DATE_S
			) AS [Всего]
		FROM
			(
				SELECT DISTINCT DATE_S
				FROM dbo.HotlineChatView WITH(NOEXPAND)
			) AS z
		ORDER BY DATE_S DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[HOTLINE_DAY_STAT] TO rl_report;
GO
