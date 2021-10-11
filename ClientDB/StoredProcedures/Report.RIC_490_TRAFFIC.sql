USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[RIC_490_TRAFFIC]
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
			NAME AS [Месяц], TOTAL_SIZE AS [Объем], CNT AS [Кол-во пополнений],
			CONVERT(NVARCHAR(8), AVG_TIME / 3600) + ':' + CONVERT(NVARCHAR(8), (AVG_TIME - (AVG_TIME / 3600) * 3600) / 60) AS [Среднее время]
		FROM
			(
				SELECT
					d.NAME, dbo.FileByteSizeToStr(SUM(CSD_ANS_SIZE + CSD_CACHE_SIZE)) AS TOTAL_SIZE, COUNT(*) AS CNT,
					dbo.MonthOf(CSD_DATE) AS MON,
					AVG(DATEPART(HOUR, CSD_DATE) * 3600 + DATEPART(MINUTE, CSD_DATE) * 60 + DATEPART(SECOND, CSD_DATE)) AS AVG_TIME
					/*,
					(
						SELECT CONVERT(NVARCHAR(64), DATEPART(DAY, CSD_DATE)) + ' ' + CONVERT(NVARCHAR(64), CSD_DATE, 108) + ', '
						FROM
							(
								SELECT DISTINCT CSD_DATE
								FROM
									IP.ClientStatDetailView z
									INNER JOIN dbo.SystemTable y ON z.CSD_SYS = y.SystemNumber
									INNER JOIN Reg.RegNodeSearchView x WITH(NOEXPAND) ON x.HostID = y.HostID AND z.CSD_DISTR = x.DistrNumber AND z.CSD_COMP = x.CompNumber
									INNER JOIN Common.Period t ON t.START = dbo.MonthOf(z.CSD_DATE)
								WHERE x.Comment LIKE '%490%' AND TYPE = 2 AND dbo.MonthOf(z.CSD_DATE) = dbo.MonthOf(a.CSD_DATE)
							) AS o_O
						ORDER BY CSD_DATE FOR XML PATH('')
					) AS [Даты пополнения]
					*/
				FROM
					IP.ClientStatDetailView a
					INNER JOIN dbo.SystemTable b ON a.CSD_SYS = b.SystemNumber
					INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.CSD_DISTR = c.DistrNumber AND a.CSD_COMP = c.CompNumber
					INNER JOIN Common.Period d ON d.START = dbo.MonthOf(CSD_DATE)
				WHERE c.Comment LIKE '%490%' AND TYPE = 2
				GROUP BY d.NAME, dbo.MonthOf(CSD_DATE)
			) AS o_O
		ORDER BY MON DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[RIC_490_TRAFFIC] TO rl_report;
GO
