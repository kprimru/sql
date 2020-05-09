USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[SystemPriceGet]
(
	@SYSTEM	INT,
	@DISTR	INT,
	@DATE	VARCHAR(20)
)
RETURNS MONEY
AS
BEGIN
	DECLARE @RES MONEY

	DECLARE @PSEDO VARCHAR(50)

	SELECT @PSEDO = DistrTypePsedo
	FROM dbo.DistrTypeTable
	WHERE DistrTypeID = @DISTR

	IF @DATE = ''
	BEGIN
		IF @PSEDO = 'MOBILE'
			SELECT @RES = SystemPriceMos
			FROM dbo.SystemTable
			WHERE SystemID = @SYSTEM
		/*ELSE IF @PSEDO = 'ONLINE2'
			SELECT @RES = SystemPriceOnline2
			FROM dbo.SystemTable
			WHERE SystemID = @SYSTEM*/
		ELSE IF EXISTS
			(
				SELECT *
				FROM dbo.SystemComposite
				WHERE ID_SYSTEM = @SYSTEM
			)
			SELECT @RES =  SUM(ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound))
			FROM dbo.SystemComposite INNER JOIN dbo.SystemTable ON ID_COMPOSITE = SystemID CROSS JOIN dbo.DistrTypeTable
			WHERE ID_SYSTEM = @SYSTEM AND DistrTypeID = @DISTR
		ELSE
			SELECT @RES = ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound)
			FROM dbo.SystemTable, dbo.DistrTypeTable
			WHERE SystemID = @SYSTEM AND DistrTypeID = @DISTR
	END
	ELSE
	BEGIN
		IF @PSEDO = 'MOBILE'
			SELECT @RES = SystemPriceMos
			FROM dbo.SystemHistoryTable b INNER JOIN dbo.SystemGroupHistoryTable c ON b.SystemGroupID = c.SystemGroupID
			WHERE SystemID = @SYSTEM AND GroupPriceDate = @DATE
		/*ELSE IF @PSEDO = 'ONLINE2'
			SELECT @RES = SystemPriceOnline2
			FROM dbo.SystemHistoryTable b INNER JOIN dbo.SystemGroupHistoryTable c ON b.SystemGroupID = c.SystemGroupID
			WHERE SystemID = @SYSTEM AND GroupPriceDate = @DATE */
		ELSE IF EXISTS
			(
				SELECT *
				FROM dbo.SystemComposite
				WHERE ID_SYSTEM = @SYSTEM
			)
			SELECT @RES =  SUM(ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound))
			FROM dbo.SystemComposite INNER JOIN dbo.SystemHistoryTable b ON ID_COMPOSITE = SystemID INNER JOIN dbo.SystemGroupHistoryTable c ON b.SystemGroupID = c.SystemGroupID CROSS JOIN dbo,DistrTypeTable
			WHERE ID_SYSTEM = @SYSTEM AND DistrTypeID = @DISTR AND GroupPriceDate = @DATE
		ELSE
			SELECT @RES = ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound)
			FROM dbo.SystemHistoryTable b INNER JOIN dbo.SystemGroupHistoryTable c ON b.SystemGroupID = c.SystemGroupID , dbo.DistrTypeTable
			WHERE SystemID = @SYSTEM AND DistrTypeID = @DISTR AND GroupPriceDate = @DATE
	END

	RETURN @RES
END
GO
