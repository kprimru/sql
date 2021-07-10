USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_SUBHOST_KBU]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
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

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		SELECT
			DATENAME(MONTH, PR_DATE) + ' ' + CONVERT(VARCHAR(20), DATEPART(YEAR, PR_DATE)) AS PR_NAME,
			VKSP, CORRECTION, VKSP_SMALL, NORM, POLKA
			/*
			PR_ID, PR_DATE, PR_NAME, VKSP, CORRECTION, CORRECTION_SUM, VKSP_SMALL, VKSP_6, VKSP_12, PRIROST,
			ROUND(PRIROST * 100 / VKSP_12, 2) AS PRIROST_PRC, NORM, POLKA
			*/

		FROM
			(
				SELECT
					PR_ID, PR_DATE, PR_NAME, VKSP, VKSP_SMALL, CORRECTION, CORRECTION_SUM,
					VKSP_6, VKSP_12, VKSP - VKSP_12 + ISNULL(CORRECTION_SUM, 0) AS PRIROST,
					NORM, POLKA
				FROM
					(
						SELECT
							PR_ID, PR_DATE, PR_NAME, VKSP, VKSP_SMALL, CORRECTION, CORRECTION_SUM, NORM, POLKA,
							CASE Q WHEN 1 THEN Subhost.VKSPGet(@SH_ID, PR_6, PR_6, PR_6, PR_6) ELSE NULL END AS VKSP_6,
							CASE Q WHEN 1 THEN Subhost.VKSPGet(@SH_ID, PR_12, PR_12, PR_12, PR_12) ELSE NULL END AS VKSP_12
						FROM
							(
								SELECT
									PR_ID, PR_NAME, PR_DATE, Subhost.VKSPGet(@SH_ID, PR_ID, PR_ID, PR_ID, PR_ID) AS VKSP,
									CASE WHEN DATEPART(MONTH, PR_DATE) % 3 = 0 THEN 1 ELSE 0 END AS Q,
									dbo.PERIOD_DELTA(PR_ID, -6) AS PR_6,
									dbo.PERIOD_DELTA(PR_ID, -12) AS PR_12,
									CORRECTION, NORM, POLKA,
									(
										SELECT SUM(CORRECTION)
										FROM
											dbo.SubhostWeightCorrection z
											INNER JOIN dbo.PeriodTable x ON z.ID_PERIOD = x.PR_ID
										WHERE z.ID_SUBHOST = @SH_ID AND x.PR_DATE <= a.PR_DATE AND x.PR_DATE >= DATEADD(MONTH, -11, a.PR_DATE)
									) AS CORRECTION_SUM,
									VKSP AS VKSP_SMALL
								FROM
									dbo.PeriodTable a
									LEFT OUTER JOIN dbo.SubhostWeightCorrection b ON b.ID_PERIOD = PR_ID AND b.ID_SUBHOST = @SH_ID
									LEFT OUTER JOIN dbo.SubhostVKSP c ON c.ID_PERIOD = PR_ID AND c.ID_SUBHOST = @SH_ID
									LEFT OUTER JOIN dbo.SubhostNorm d ON d.ID_PERIOD = PR_ID AND d.ID_SUBHOST = @SH_ID
									LEFT OUTER JOIN dbo.SubhostPolka e ON e.ID_PERIOD = PR_ID AND e.ID_SUBHOST= @SH_ID
								WHERE PR_DATE <= @PR_DATE AND PR_DATE >= '20160101'
							) AS a
					) AS a
				) AS a
		ORDER BY PR_DATE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
