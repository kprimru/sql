USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTRACT_SUM_SELECT]
	@CUSTOMER	INT,
	@DATE		VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TaxRate Decimal(8,2)

	SELECT @TaxRate = t.TaxRate / 100
	FROM dbo.TaxTable t
	INNER JOIN dbo.TaxSaleObjectTable TS ON T.TaxId = TS.TaxId
	WHERE SaleObjectID = 1

	IF @DATE = ''
		SELECT SystemPrefix, SystemName, DistrTypeName, 
			DistrTypeCoefficient, DistrTypeNet, 
			PriceAbonement, DiscountRate, FixedSum, SystemServicePrice, MonthCount, BeginMonth, 
			SystemPriceModeName, SystemSet, MonthPrice, SysPrice,
			ROUND(SysPrice * @TaxRate, 2) As SysPriceNDS, ROUND(SysPrice * @TaxRate, 2) + SysPrice AS SysPriceTotalNDS
		FROM
			(
				SELECT
					SystemPrefix, SystemName, DistrTypeMainStr AS DistrTypeName, 
					DistrTypeCoefficient, DistrTypeNet, 
					PriceAbonement, DiscountRate, FixedSum, SystemServicePrice, MonthCount, BeginMonth, 
					SystemPriceModeName, SystemSet, MonthPrice, SystemOrder, SystemGroupOrder,						
					CASE SystemPriceModeName
						WHEN 'PriceAbonement' THEN
							/*CASE 
								WHEN DistrTypePsedo = 'NET50' THEN ROUND(SystemServicePrice * DistrTypeCoefficient, -1)
								ELSE */
								--PriceAbonement * MonthPrice
								/*dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '')*/ --ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound)
							/*END*/
							PriceAbonement * MonthPrice--dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '')
						WHEN 'DiscountRate' THEN
							/*CASE 
								WHEN DistrTypePsedo = 'NET50' THEN ROUND(ROUND(SystemServicePrice * DistrTypeCoefficient, -1) * (100 - DiscountRate) / 100, 2)
								ELSE */
								--ROUND(
								/*ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound)*/ 
								--MonthPrice
								/*dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '')*/ 
								--* (100 - DiscountRate) / 100, 2)
							/*END*/
							ROUND(dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '') * (100 - DiscountRate) / 100, 2)
						WHEN 'FixedSum' THEN FixedSum
						ELSE 0
					END AS SysPrice
				FROM 
					dbo.TempCustomerSystemsTable a
					INNER JOIN dbo.SystemTable b ON b.SystemID = a.SystemID 
					INNER JOIN dbo.SystemGroupTable c ON c.SystemGroupID = b.SystemGroupID 
					INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = a.DistrTypeID 
				WHERE CustomerID = @CUSTOMER
			) AS o_O
		ORDER BY SystemGroupOrder, SystemOrder
	ELSE
		SELECT SystemPrefix, SystemName, DistrTypeName, 
			DistrTypeCoefficient, DistrTypeNet, 
			PriceAbonement, DiscountRate, FixedSum, SystemServicePrice, MonthCount, BeginMonth, 
			SystemPriceModeName, SystemSet, MonthPrice, SysPrice,
			ROUND(SysPrice * @TaxRate, 2) As SysPriceNDS, ROUND(SysPrice * @TaxRate, 2) + SysPrice AS SysPriceTotalNDS
		FROM
			(
				SELECT 
					SystemPrefix, SystemName, DistrTypeMainStr AS DistrTypeName, 
					DistrTypeCoefficient, DistrTypeNet, 
					PriceAbonement, DiscountRate, FixedSum, SystemServicePrice, MonthCount, BeginMonth, 
					SystemPriceModeName, SystemSet, MonthPrice, SystemGroupOrder, SystemOrder,
					CASE SystemPriceModeName
						WHEN 'PriceAbonement' THEN
							/*CASE 
								WHEN DistrTypePsedo = 'NET50' THEN ROUND(SystemServicePrice * DistrTypeCoefficient, -1)
								ELSE */
								--PriceAbonement * MonthPrice
								/*dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '')*/ --ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound)
							/*END*/
							PriceAbonement * dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, @DATE)
						WHEN 'DiscountRate' THEN
							/*CASE 
								WHEN DistrTypePsedo = 'NET50' THEN ROUND(ROUND(SystemServicePrice * DistrTypeCoefficient, -1) * (100 - DiscountRate) / 100, 2)
								ELSE */
								--ROUND(
								/*ROUND(SystemServicePrice * DistrTypeCoefficient, DistrTypeRound)*/ 
								--MonthPrice
								/*dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '')*/ 
								--* (100 - DiscountRate) / 100, 2)
							/*END*/
							ROUND(dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, @DATE) * (100 - DiscountRate) / 100, 2)
						WHEN 'FixedSum' THEN FixedSum
						ELSE 0
					END AS SysPrice
				FROM 
					dbo.TempCustomerSystemsTable a
					INNER JOIN dbo.SystemHistoryTable b ON a.SystemID = b.SystemID 
					INNER JOIN dbo.SystemGroupHistoryTable c ON b.SystemGroupID = c.SystemGroupID 
					INNER JOIN dbo.DistrTypeTable d ON a.DistrTypeID = d.DistrTypeID 
				WHERE PriceDate = @DATE 
					AND GroupPriceDate = @DATE 
					AND CustomerID = @CUSTOMER
			) AS o_O		
		ORDER BY SystemGroupOrder, SystemOrder
END
