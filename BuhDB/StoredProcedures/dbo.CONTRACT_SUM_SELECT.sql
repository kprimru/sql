USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CONTRACT_SUM_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CONTRACT_SUM_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CONTRACT_SUM_SELECT]
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

    SELECT
        SystemPrefix, SystemName, DistrTypeName, DistrTypeCoefficient, DistrTypeNet,
        PriceAbonement, DiscountRate, FixedSum, SystemServicePrice, MonthCount, BeginMonth,
        SystemPriceModeName, SystemSet, SP.MonthPrice, SysPrice, IsGenerated,
        ROUND(SysPrice * @TaxRate, 2) As SysPriceNDS, ROUND(SysPrice * @TaxRate, 2) + SysPrice AS SysPriceTotalNDS
    FROM dbo.TempCustomerSystemsTable a
    INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = a.DistrTypeID
    CROSS APPLY
    (
        SELECT
            SystemPrefix, SystemName, SystemServicePrice, SystemOrder, SystemGroupOrder
        FROM dbo.SystemTable b
        INNER JOIN dbo.SystemGroupTable c ON c.SystemGroupID = b.SystemGroupID
        WHERE b.SystemID = a.SystemID
            AND @Date = ''

        UNION ALL

        SELECT
            SystemPrefix, SystemName, SystemServicePrice, SystemOrder, SystemGroupOrder
        FROM dbo.SystemHistoryTable b
        INNER JOIN dbo.SystemGroupHistoryTable c ON c.SystemGroupID = b.SystemGroupID
        WHERE b.SystemID = a.SystemID
            AND PriceDate = @DATE
            AND GroupPriceDate = @DATE
    ) AS S
    CROSS APPLY
    (
        SELECT
            CASE SystemPriceModeName
                WHEN 'PriceAbonement' THEN
                    PriceAbonement * dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, @DATE)
                WHEN 'DiscountRate' THEN
                    ROUND(dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, @DATE) * (100 - DiscountRate) / 100, 2)
                WHEN 'FixedSum' THEN FixedSum
                    ELSE 0
            END AS SysPrice,
            IsGenerated = Cast(0 AS Bit)

        UNION ALL

        SELECT [dbo].[DefaultDeliveryPriceGet](), IsGenerated = Cast(1 AS Bit)
        WHERE d.GenerateRow = 1
    ) AS P
	CROSS APPLY
	(
		SELECT
			CASE MonthPriceMode
				WHEN 'Discount' THEN Cast(Ceiling(MonthPrice * (1 + MonthPriceInflation / 100) * (100 - MonthPriceDiscount) / 100) AS Money)
				WHEN 'Fixed' THEN MonthPriceFixed
				WHEN 'Price' THEN MonthPrice
				ELSE MonthPrice
			END AS MonthPrice
	) AS SP
    WHERE CustomerID = @CUSTOMER
    ORDER BY IsGenerated DESC, SystemGroupOrder, SystemOrder

    /*

			(
				SELECT
					SystemPrefix, SystemName, DistrTypeMainStr AS DistrTypeName,
					DistrTypeCoefficient, DistrTypeNet,
					PriceAbonement, DiscountRate, FixedSum, SystemServicePrice, MonthCount, BeginMonth,
					SystemPriceModeName, SystemSet, MonthPrice, SystemOrder, SystemGroupOrder,
					CASE SystemPriceModeName
						WHEN 'PriceAbonement' THEN
							PriceAbonement * MonthPrice
						WHEN 'DiscountRate' THEN
							ROUND(dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, '') * (100 - DiscountRate) / 100, 2)
						WHEN 'FixedSum' THEN FixedSum
						ELSE 0
					END AS SysPrice
				FROM

					INNER JOIN dbo.SystemTable b ON b.SystemID = a.SystemID
					INNER JOIN dbo.SystemGroupTable c ON c.SystemGroupID = b.SystemGroupID


			) AS o_O
		ORDER BY SystemGroupOrder, SystemOrder
    */

    /*
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
							PriceAbonement * MonthPrice
						WHEN 'DiscountRate' THEN
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
							PriceAbonement * dbo.SystemPriceGet(a.SystemID, a.DistrTypeID, @DATE)
						WHEN 'DiscountRate' THEN
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
	*/
END
GO
GRANT EXECUTE ON [dbo].[CONTRACT_SUM_SELECT] TO DBCount;
GO
