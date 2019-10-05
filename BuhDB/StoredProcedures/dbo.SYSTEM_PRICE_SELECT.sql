USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_PRICE_SELECT]
	@SYSTEM	VARCHAR(150),
	@DISTR	VARCHAR(150),
	@DATE	VARCHAR(50) = '',
	@DEPO	BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DCOEF DECIMAL(8, 4)
	DECLARE @DROUND SMALLINT
			
	SELECT @DCOEF = DistrTypeCoefficient, @DROUND = DistrTypeRound
	FROM dbo.DistrTypeTable d
	WHERE d.DistrTypeName = @DISTR

	IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN 
				(
					'SKBEM',
					'SKJEM',
					'SBOEM',
					'SKUEM'
				)
		) 
	BEGIN
		SET @DCOEF = 1
		SET @DROUND = 2
	END
	/*
	ELSE IF @SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN 
				(
					'SKBP',
					'SKBO',
					'SKBB',
					'SKJE',
					'SKJP',
					'SKJO',
					'SKJB',
					'SBOE',
					'SBOP',
					'SBOO',
					'SBOB',
					'SKUE',
					'SKUP',
					'SKUO',
					'SKUB',
					'SKZO',
					'SKZB'
				)
		) AND @DISTR IN ('Îíëàéí-âåðñèÿ Ïàðîëü')		
	BEGIN
		SET @DCOEF = 1.1
		SET @DROUND = 2
	END
	*/
	ELSE IF (@SYSTEM IN
		(
			SELECT SystemName
			FROM dbo.SystemTable
			WHERE SystemReg IN 
				(
					'SKBO', 'SKUO', 'SBOO', 'SKJP', 'SKZO', 'SKZB'					
				)
		) AND @DISTR IN ('ÎÂÌ-Ô (1;2)')
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
		) AND @DISTR IN ('ÎÂÊ')
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
		) AND @DISTR IN ('ÎÂÌ-Ô (1;2)')
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
		) AND @DISTR IN ('ÎÂÑ (5 ÎÄ)')		
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
		) AND @DISTR IN ('ÎÂÑ (10 ÎÄ)')		
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
		) AND @DISTR IN ('ÎÂÑ (20 ÎÄ)')		
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
		) AND @DISTR IN ('ÎÂÑ (50 ÎÄ)')		
	BEGIN
		SET @DCOEF = 2.86
		SET @DROUND = 2
	END

	IF @DATE = ''
	BEGIN
		IF @DEPO = 0
			SELECT ROUND(SystemServicePrice * @DCOEF, @DROUND) AS MONTH_PRICE
			FROM dbo.SystemTable
			WHERE SystemName = @SYSTEM
		ELSE IF @SYSTEM = 'ÊîíñóëüòàíòÞðèñò' AND GETDATE() >= '20170601' AND GETDATE() <= '20170630'
			SELECT ROUND(4300 * DistrTypeCoefficient, DistrTypeRound) AS MONTH_PRICE
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
							ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF + 
								CASE
									WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF, @DROUND) < ROUND(SystemServicePrice * @DCOEF, @DROUND) * 0.85 THEN 10
									ELSE 0
								END
							, @DROUND)
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
			SELECT ROUND(SystemServicePrice * @DCOEF, @DROUND) AS MONTH_PRICE
			FROM dbo.SystemHistoryTable
			WHERE SystemName = @SYSTEM AND PriceDate = @DATE
		ELSE IF @SYSTEM = 'ÊîíñóëüòàíòÞðèñò' AND @DATE >= '20170601' AND @DATE <= '20170630'
			SELECT ROUND(4300 * DistrTypeCoefficient, DistrTypeRound) AS MONTH_PRICE
			FROM dbo.DistrTypeTable
			WHERE DistrTypeName = @DISTR
		ELSE
			SELECT
				ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF + 
					CASE
						WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * 0.85)/10.0) * 10, -1) * @DCOEF, @DROUND) < ROUND(SystemServicePrice * @DCOEF, @DROUND) * 0.85 THEN 10
						ELSE 0
					END
							, @DROUND)
				AS MONTH_PRICE
			FROM dbo.SystemHistoryTable a
			WHERE SystemName = @SYSTEM AND PriceDate = @DATE
	END
END
