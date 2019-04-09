USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[CLIENT_PRICE_CHANGE]
	@BEGIN	UNIQUEIDENTIFIER,
	@END	UNIQUEIDENTIFIER,
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BEGIN_DATE SMALLDATETIME
	DECLARE @END_DATE SMALLDATETIME
	
	SELECT @BEGIN_DATE = START
	FROM Common.Period
	WHERE ID = @BEGIN
	
	SELECT @END_DATE = START
	FROM Common.Period
	WHERE ID = @END
	
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
							ELSE ROUND(ROUND(op.PRICE * dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE), dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE)) * (100 - ISNULL(DF_DISCOUNT, 0)) / 100, 2)
						END AS OLD_PRICE,
						DSS_REPORT * CASE 
							WHEN ISNULL(DF_FIXED_PRICE, 0) <> 0 THEN DF_FIXED_PRICE
							ELSE ROUND(ROUND(np.PRICE * dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE), dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE)) * (100 - ISNULL(DF_DISCOUNT, 0)) / 100, 2)
						END AS NEW_PRICE,
						ROUND(ROUND(op.PRICE * dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE), dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @BEGIN_DATE)) * 1.18, 2) AS OLD_PRICE_NDS,			
						ROUND(ROUND(np.PRICE * dbo.DistrCoef(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE), dbo.DistrCoefRound(a.SystemID, a.DistrTypeID, a.SystemTypeName, @END_DATE)) * 1.18, 2) AS NEW_PRICE_NDS
					FROM 
						dbo.ClientDistrView a WITH(NOEXPAND)			
						INNER JOIN Price.SystemPrice op ON a.SystemID = op.ID_SYSTEM AND op.ID_MONTH = @BEGIN
						INNER JOIN Price.SystemPrice np ON a.SystemID = np.ID_SYSTEM AND np.ID_MONTH = @END
						LEFT OUTER JOIN dbo.DBFDistrView ON SystemBaseName = SYS_REG_NAME AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
					WHERE a.ID_CLIENT = @CLIENT AND DS_REG = 0
				) AS a
			OUTER APPLY Common.TaxDefaultSelect(@BEGIN_DATE) AS b
			OUTER APPLY Common.TaxDefaultSelect(@END_DATE)	AS e
		) AS a
	ORDER BY SystemOrder, DISTR, COMP
END
