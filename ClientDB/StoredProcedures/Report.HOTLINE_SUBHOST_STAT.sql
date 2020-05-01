USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[HOTLINE_SUBHOST_STAT]
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

		SELECT
			SH_CAPTION AS [Подхост],
			ComplectCount AS [Количество комплектов],
			QUEST_CLIENT AS [Количество комплектов с которыми был сеанс чата],
			QUEST_COUNT AS [Количество чатов],
			CONVERT(DECIMAL(8, 2), ROUND(100.0 * QUEST_CLIENT / ComplectCount, 2)) AS [% внедрения]
		FROM
			(
				SELECT
					SH_CAPTION,
					(
						SELECT COUNT(DISTINCT COMPLECT)
						FROM Reg.RegNodeSearchView a WITH(NOEXPAND)
						WHERE a.SubhostName = SH_NAME
							AND DS_REG = 0
							AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП', 'ОДД')
					) AS ComplectCount,
					(
						SELECT COUNT(DISTINCT b.COMPLECT)
						FROM
							dbo.HotlineChat a
							INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
							INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber AND c.HostID = b.HostID
						WHERE b.SubhostName = SH_NAME
							AND DS_REG = 0
							AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП', 'ОДД')
					) AS QUEST_CLIENT,
					(
						SELECT COUNT(*)
						FROM
							dbo.HotlineChat a
							INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
							INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber AND c.HostID = b.HostID
						WHERE b.SubhostName = SH_NAME
							AND DS_REG = 0
							AND SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП', 'ОДД')
					) AS QUEST_COUNT
				FROM
					(
						SELECT 'Владивосток' AS SH_CAPTION, '' AS SH_NAME
						UNION ALL
						SELECT 'Славянка' AS CAPTION, 'Л1' AS SubhostName
						UNION ALL
						SELECT 'Находка' AS CAPTION, 'Н1' AS SubhostName
						UNION ALL
						SELECT 'Уссурийск' AS CAPTION, 'У1' AS SubhostName
						UNION ALL
						SELECT 'Артем' AS CAPTION, 'М' AS SubhostName
					) AS SH
			) AS o_O
		WHERE ComplectCount <> 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[HOTLINE_SUBHOST_STAT] TO rl_report;
GO