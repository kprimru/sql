USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[GROW_STANDARD_GET]
	@PR_ALG	SMALLINT,
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
		WHERE PR_ID = @PR_ALG

		DECLARE @RES	DECIMAL(10, 4)

		IF @PR_DATE >= '20120601'
		BEGIN
			SELECT @RES = ISNULL(
					(
						SELECT GS_VALUE
						FROM Ric.GrowStandard
						WHERE GS_ID_QUARTER = dbo.PeriodQuarter(@PR_ID)
					),
					(
						SELECT TOP 1 GS_VALUE
						FROM
							Ric.GrowStandard
							INNER JOIN dbo.Quarter ON GS_ID_QUARTER = QR_ID
						WHERE QR_BEGIN <= (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
						ORDER BY QR_BEGIN DESC
					))
		END

		SELECT @RES AS GS_VALUE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Ric].[GROW_STANDARD_GET] TO rl_ric_kbu;
GO
