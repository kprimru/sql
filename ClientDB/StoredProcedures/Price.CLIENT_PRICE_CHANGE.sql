USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[CLIENT_PRICE_CHANGE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[CLIENT_PRICE_CHANGE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[CLIENT_PRICE_CHANGE]
	@BEGIN	UNIQUEIDENTIFIER,
	@END	UNIQUEIDENTIFIER,
	@CLIENT	INT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@BEGIN_DATE		SmallDateTime,
		@END_DATE		SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @BEGIN_DATE = START
		FROM [Common].[Period]
		WHERE ID = @BEGIN;

		SELECT @END_DATE = START
		FROM [Common].[Period]
		WHERE ID = @END;

		SELECT
			DistrStr, DistrTypeName,
			CASE
				WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN 'Фикс.сумма: ' + CONVERT(VARCHAR(20), CONVERT(DECIMAL(10, 2), DF_FIXED_PRICE))
				WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN 'Скидка: ' + CONVERT(VARCHAR(20), CONVERT(INT, DF_DISCOUNT)) + ' %'
				ELSE 'Нет'
			END AS SPEC_CONDITION,
			OLD_PRICE, NEW_PRICE, NEW_PRICE - OLD_PRICE AS PRICE_DELTA,
			OLD_PRICE_NDS, NEW_PRICE_NDS, NEW_PRICE_NDS - OLD_PRICE_NDS AS PRICE_NDS_DELTA,
			ROUND(100 * (NEW_PRICE - OLD_PRICE) / OLD_PRICE, 2) AS INFLATION
		FROM
		(
			SELECT
				DistrStr, DistrTypeName, SystemOrder, DISTR, COMP,
				DF_DISCOUNT, DF_FIXED_PRICE,
				NULLIF(OLD_PRICE, 0) AS OLD_PRICE, NULLIF(NEW_PRICE, 0) AS NEW_PRICE,
				ROUND(OLD_PRICE * b.TOTAL_RATE, 2) AS OLD_PRICE_NDS,
				ROUND(NEW_PRICE * b.TOTAL_RATE, 2) AS NEW_PRICE_NDS
			FROM
			(
				SELECT
					DistrStr, DistrTypeName, SystemOrder, DISTR, COMP,
					DF_DISCOUNT, DF_FIXED_PRICE,
					DSS_REPORT * CASE
						WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN DF_FIXED_PRICE
						ELSE ROUND([dbo].[DistrPrice](op.PRICE, op.[DistrCoef], op.[DistrCoefRound]) * (100 - ISNULL(DF_DISCOUNT, 0)) / 100, 2)
					END AS OLD_PRICE,
					DSS_REPORT * CASE
						WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN DF_FIXED_PRICE
						ELSE ROUND([dbo].[DistrPrice](np.PRICE, np.[DistrCoef], np.[DistrCoefRound]) * (100 - ISNULL(DF_DISCOUNT, 0)) / 100, 2)
					END AS NEW_PRICE
				FROM
				dbo.ClientDistrView a WITH(NOEXPAND)
				CROSS APPLY
				(
					SELECT
						[Price]				= op.[Price],
						[DistrCoef]			= dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE),
						[DistrCoefRound]	= dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE)
					FROM [Price].[Systems:Price@Get](@BEGIN_DATE) AS op
					WHERE op.[System_Id] = a.[SystemID]
				) AS op
				CROSS APPLY
				(
					SELECT
						[Price]				= np.[Price],
						[DistrCoef]			= dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE),
						[DistrCoefRound]	= dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE)
					FROM [Price].[Systems:Price@Get](@END_DATE) AS np
					WHERE np.[System_Id] = a.[SystemID]
				) AS np
				LEFT JOIN dbo.DBFDistrView ON SystemBaseName = SYS_REG_NAME AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
				WHERE a.ID_CLIENT = @CLIENT AND DS_REG = 0
			) AS a
			OUTER APPLY Common.TaxDefaultSelect(@BEGIN_DATE) AS b
			OUTER APPLY Common.TaxDefaultSelect(@END_DATE)	AS e
		) AS a
		ORDER BY SystemOrder, DISTR, COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[CLIENT_PRICE_CHANGE] TO rl_price_history;
GO
