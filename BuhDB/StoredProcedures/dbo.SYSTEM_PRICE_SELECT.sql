USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_PRICE_SELECT]
	@SYSTEM	VARCHAR(150),
	@DISTR	VARCHAR(150),
	@DATE	VARCHAR(50) = '',
	@DEPO	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DCOEF DECIMAL(8, 4)
	DECLARE @DROUND SMALLINT
	DECLARE @TotalCoef Numeric(12, 4);

	SET @TotalCoef = [dbo].[PriceCoef@Get]();

	SELECT @DCOEF = DistrTypeCoefficient, @DROUND = DistrTypeRound
	FROM dbo.DistrTypeTable d
	WHERE d.DistrTypeName = @DISTR

	IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN ('SKBEM', 'SKJEM', 'SBOEM','SKUEM')
		) BEGIN
		SET @DCOEF = 1
		SET @DROUND = 2
	END ELSE IF (@SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKBO', 'SKUO', 'SBOO', 'SKJP', 'SKZO', 'SKZB'
				)
		) AND @DISTR IN ('ОВМ-Ф(3)')
		)
		OR
		(@SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKZO'
				)
		) AND @DISTR IN ('ОВК')
		)
	BEGIN
		SET @DCOEF = 1.3
		SET @DROUND = 2
	END
	ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKUP', 'SBOP'
				)
		) AND @DISTR IN ('ОВМ-Ф(3)')
	BEGIN
		SET @DCOEF = 1.5
		SET @DROUND = 2
	END
	ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKUP', 'SBOP'
				)
		) AND @DISTR IN ('ОВС (5 ОД)')
	BEGIN
		SET @DCOEF = 2.3
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKUP', 'SBOP'
				)
		) AND @DISTR IN ('ОВС (10 ОД)')
	BEGIN
		SET @DCOEF = 2.52
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKUP', 'SBOP'
				)
		) AND @DISTR IN ('ОВС (20 ОД)')
	BEGIN
		SET @DCOEF = 2.64
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKUP', 'SBOP'
				)
		) AND @DISTR IN ('ОВС (50 ОД)')
	BEGIN
		SET @DCOEF = 2.86
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO'
				)
		) AND @DISTR IN ('ОВМ1')
	BEGIN
		SET @DCOEF = 1.25
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO'
				)
		) AND @DISTR IN ('ОВМ2')
	BEGIN
		SET @DCOEF = 1.5
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO'
				)
		) AND @DISTR IN ('ОВМ3')
	BEGIN
		SET @DCOEF = 2
		SET @DROUND = 2
	END ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN
				(
					'SKBP', 'SKBO', 'SKBB', 'SKJE', 'SKJP', 'SKJO', 'SKJB', 'SKUE', 'SKUP', 'SKUO', 'SKUB', 'SBOE', 'SBOP', 'SBOO', 'SBOB', 'SKZB', 'SKZO'
				)
		) AND @DISTR IN ('ОВМ5')
	BEGIN
		SET @DCOEF = 3
		SET @DROUND = 2
	END

	IF @DATE = ''
	BEGIN
		IF @DEPO = 0
			SELECT Round(@TotalCoef * ROUND(SystemServicePrice * @DCOEF, @DROUND), 2) AS MONTH_PRICE
			FROM dbo.SystemTable
			WHERE SystemName = @SYSTEM
		ELSE IF @SYSTEM = 'КонсультантЮрист' AND GETDATE() >= '20170601' AND GETDATE() <= '20170630'
			SELECT Round(@TotalCoef * ROUND(4300 * DistrTypeCoefficient, DistrTypeRound), 2) AS MONTH_PRICE
			FROM dbo.DistrTypeTable
			WHERE DistrTypeName = @DISTR
		ELSE
			SELECT
				/*
				CASE
					WHEN EXISTS
						(
							SELECT *
							FROM dbo.SystemComposite
							WHERE SystemID = ID_SYSTEM
						)
						THEN
								(
									SELECT
										SUM(ROUND(ROUND(CEILING(CEILING(z.SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF, @DROUND) < ROUND(SystemServicePrice * @DCOEF, @DROUND) * 0.85 THEN 10
												ELSE 0
											END
											, @DROUND))
									FROM
										dbo.SystemTable z
										INNER JOIN dbo.SystemComposite ON ID_COMPOSITE = z.SystemID
									WHERE ID_SYSTEM = a.SystemID
								)
						ELSE
						*/
						Round(@TotalCoef *
							ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF +
								CASE
									WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF, @DROUND) < ROUND(SystemServicePrice * @DCOEF, @DROUND) * 0.85 THEN 10
									ELSE 0
								END
							, @DROUND)
							, 2)
				/*END */AS MONTH_PRICE
			FROM dbo.SystemTable a
			WHERE SystemName = @SYSTEM

						/*
			SELECT
				--ROUND(ROUND(SystemServicePrice * 0.85, -1) * DistrTypeCoefficient, DistrTypeRound) AS MONTH_PRICE
				ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * DistrTypeCoefficient +
					CASE
						WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * DistrTypeCoefficient, DistrTypeRound) < ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound) * 0.85 THEN 10
						ELSE 0
					END
				, DistrTypeRound) AS MONTH_PRICE
			FROM dbo.SystemTable
			WHERE SystemName = @SYSTEM
			*/
	END
	ELSE
	BEGIN
		IF @DEPO = 0
			SELECT Round(@TotalCoef * ROUND(SystemServicePrice * @DCOEF, @DROUND), 2) AS MONTH_PRICE
			FROM dbo.SystemHistoryTable
			WHERE SystemName = @SYSTEM AND PriceDate = @DATE
		ELSE IF @SYSTEM = 'КонсультантЮрист' AND @DATE >= '20170601' AND @DATE <= '20170630'
			SELECT Round(@TotalCoef * ROUND(4300 * DistrTypeCoefficient, DistrTypeRound), 2) AS MONTH_PRICE
			FROM dbo.DistrTypeTable
			WHERE DistrTypeName = @DISTR
		ELSE
			SELECT
				Round(@TotalCoef *
				ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF +
					CASE
						WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF, @DROUND) < ROUND(SystemServicePrice * @DCOEF, @DROUND) * 0.85 THEN 10
						ELSE 0
					END
							, @DROUND)
				, 2) AS MONTH_PRICE
			FROM dbo.SystemHistoryTable a
			WHERE SystemName = @SYSTEM AND PriceDate = @DATE
	END
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_PRICE_SELECT] TO DBCount;
GO
