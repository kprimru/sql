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
				[dbo].[DistrPrice](op.PRICE, op.[DistrCoef], op.[DistrCoefRound]) AS OLD_PRICE,
				ROUND([dbo].[DistrPrice](op.PRICE, op.[DistrCoef], op.[DistrCoefRound]) * b.TOTAL_RATE, 2) AS OLD_PRICE_NDS,
				[dbo].[DistrPrice](np.PRICE, np.[DistrCoef], np.[DistrCoefRound]) AS NEW_PRICE,
				ROUND([dbo].[DistrPrice](np.PRICE, np.[DistrCoef], np.[DistrCoefRound]) * e.TOTAL_RATE, 2) AS NEW_PRICE_NDS
			FROM
				dbo.SystemTable a
				-- TODO отсутствует зависимость от типа системы
				CROSS APPLY
				(
					SELECT
						[Price]				= op.[Price],
						[DistrCoef]			= op.[DistrCoef],
						[DistrCoefRound]	= op.[DistrCoefRound]
					FROM [Price].[DistrPriceWrapper](a.SystemID, @NET, NULL, NULL, @BEGIN_DATE) AS op
				) AS op
				CROSS APPLY
				(
					SELECT
						[Price]				= np.[Price],
						[DistrCoef]			= np.[DistrCoef],
						[DistrCoefRound]	= np.[DistrCoefRound]
					FROM [Price].[DistrPriceWrapper](a.SystemID, @NET, NULL, NULL, @END_DATE) AS np
				) AS np
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
