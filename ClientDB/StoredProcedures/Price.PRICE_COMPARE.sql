USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_COMPARE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_COMPARE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[PRICE_COMPARE]
	@BEGIN	UNIQUEIDENTIFIER,
	@END	UNIQUEIDENTIFIER,
	@NET	INT
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

		DECLARE @BEGIN_DATE SMALLDATETIME
		DECLARE @END_DATE SMALLDATETIME

		SELECT @BEGIN_DATE = START
		FROM Common.Period
		WHERE ID = @BEGIN

		SELECT @END_DATE = START
		FROM Common.Period
		WHERE ID = @END

		SELECT
			SystemShortName,
			OLD_PRICE, NEW_PRICE, NEW_PRICE - OLD_PRICE AS PRICE_DELTA,
			OLD_PRICE_NDS, NEW_PRICE_NDS, NEW_PRICE_NDS - OLD_PRICE_NDS AS PRICE_NDS_DELTA,
			ROUND(100 * (NEW_PRICE - OLD_PRICE) / NULLIF(OLD_PRICE, 0), 2) AS INFLATION
		FROM
			(
				SELECT
					SystemShortName, SystemOrder,
					ROUND(op.PRICE * dbo.DistrCoef(a.SystemID, @NET, '', @BEGIN_DATE), dbo.DistrCoefRound(a.SystemID, @NET, '', @BEGIN_DATE)) AS OLD_PRICE,
					ROUND(ROUND(op.PRICE * dbo.DistrCoef(a.SystemID, @NET, '', @BEGIN_DATE), dbo.DistrCoefRound(a.SystemID, @NET, '', @BEGIN_DATE)) * b.TOTAL_RATE, 2) AS OLD_PRICE_NDS,
					ROUND(np.PRICE * dbo.DistrCoef(a.SystemID, @NET, '', @END_DATE), dbo.DistrCoefRound(a.SystemID, @NET, '', @END_DATE)) AS NEW_PRICE,
					ROUND(ROUND(np.PRICE * dbo.DistrCoef(a.SystemID, @NET, '', @END_DATE), dbo.DistrCoefRound(a.SystemID, @NET, '', @END_DATE)) * e.TOTAL_RATE, 2) AS NEW_PRICE_NDS
				FROM
					dbo.SystemTable a
					INNER JOIN Price.SystemPrice op ON a.SystemID = op.ID_SYSTEM AND op.ID_MONTH = @BEGIN
					INNER JOIN Price.SystemPrice np ON a.SystemID = np.ID_SYSTEM AND np.ID_MONTH = @END
					OUTER APPLY Common.TaxDefaultSelect(@BEGIN_DATE) AS b
					OUTER APPLY Common.TaxDefaultSelect(@END_DATE)	AS e
			) AS a
		ORDER BY SystemOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_COMPARE] TO rl_price_history;
GO
