USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_PRICE_LIST_SELECT]
	@PSEDO	VARCHAR(64),
	@NOTE	BIT = 1,
	@TYPE	VARCHAR(64) = '1',
	@ShowExpired Bit = 1,
	@Date   VarChar(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TaxRate Decimal(8,2)

	SELECT @TaxRate = (t.TaxRate + 100) / 100
	FROM dbo.TaxTable t
	INNER JOIN dbo.TaxSaleObjectTable TS ON T.TaxId = TS.TaxId
	WHERE SaleObjectID = 1

	--SELECT @TaxRate

	DECLARE @DCOEF DECIMAL(8, 4)
	DECLARE @DROUND SMALLINT

	DECLARE @DEPO	DECIMAL(8, 4)

	DECLARE @ArchDate VarChar(20);

	SELECT TOP (1) @ArchDate = PriceDate
	FROM dbo.SystemHistoryTable
	WHERE PriceDate <= @Date
	ORDER BY PriceDate DESC;

	DECLARE @TotalCoef Numeric(12, 4);

	SET @TotalCoef = [dbo].[PriceCoef@Get]();

	SET @DEPO = 0.85

	SELECT @DCOEF = DistrTypeCoefficient, @DROUND = DistrTypeRound
	FROM dbo.DistrTypeTable d
	WHERE d.DistrTypePsedo = @PSEDO
		OR d.DistrTypePsedo = 'ONLINE2' AND @PSEDO = 'ONLINE2_CLIENT'
		OR d.DistrTypePsedo = 'ONLINE3' AND @PSEDO = 'ONLINE3_CLIENT'
		OR d.DistrTypePsedo = 'OVM_1' AND @PSEDO = 'OVM_1_CL'
		OR d.DistrTypePsedo = 'OVM_2' AND @PSEDO = 'OVM_2_CL'
		OR d.DistrTypePsedo = 'OVM_3' AND @PSEDO = 'OVM_3_CL'
		OR d.DistrTypePsedo = 'OVM_F12' AND @PSEDO = 'OVM_F12_CL'
		OR d.DistrTypePsedo = 'OVM_F10' AND @PSEDO = 'OVM_F10_CL'
		OR d.DistrTypePsedo = 'OVM_F01' AND @PSEDO = 'OVM_F01_CL'
		OR d.DistrTypePsedo = 'ONLINE_EXP' AND @PSEDO = 'ONLINE_EXP_CLIENT'
		OR d.DistrTypePsedo = 'LOCAL' AND @PSEDO = 'DEPO_LOCAL'
		OR d.DistrTypePsedo = 'FLASH' AND @PSEDO = 'DEPO_FLASH'
		OR d.DistrTypePsedo = 'NET1' AND @PSEDO = 'DEPO_NET1'
		OR d.DistrTypePsedo = 'NET_SMALL' AND @PSEDO = 'DEPO_NET_SMALL'
		OR d.DistrTypePsedo = 'NET50' AND @PSEDO = 'DEPO_NET50'
		OR d.DistrTypePsedo = 'ONLINE_EXP' AND @PSEDO = 'DEPO_ONLINE_EXP'
		OR d.DistrTypePsedo = 'ONLINE_EXP' AND @PSEDO = 'DEPO_ONLINE_EXP_CLIENT'
		OR d.DistrTypePsedo = 'ONLINE2' AND @PSEDO = 'DEPO_ONLINE2'
		OR d.DistrTypePsedo = 'ONLINE2' AND @PSEDO = 'DEPO_ONLINE2_CLIENT'
		OR d.DistrTypePsedo = 'ONLINE3' AND @PSEDO = 'DEPO_ONLINE3'
		OR d.DistrTypePsedo = 'ONLINE3' AND @PSEDO = 'DEPO_ONLINE3_CLIENT'
		OR d.DistrTypePsedo = 'OVM_1' AND @PSEDO = 'DEPO_OVM_1'
		OR d.DistrTypePsedo = 'OVM_1' AND @PSEDO = 'DEPO_OVM_1_CL'
		OR d.DistrTypePsedo = 'OVM_2' AND @PSEDO = 'DEPO_OVM_2'
		OR d.DistrTypePsedo = 'OVM_2' AND @PSEDO = 'DEPO_OVM_2_CL'
		OR d.DistrTypePsedo = 'OVM_3' AND @PSEDO = 'DEPO_OVM_3'
		OR d.DistrTypePsedo = 'OVM_3' AND @PSEDO = 'DEPO_OVM_3_CL'
		OR d.DistrTypePsedo = 'OVM_F12' AND @PSEDO = 'DEPO_OVM_F12'
		OR d.DistrTypePsedo = 'OVM_F12' AND @PSEDO = 'DEPO_OVM_F12_CL'
		OR d.DistrTypePsedo = 'OVM_F10' AND @PSEDO = 'DEPO_OVM_F10'
		OR d.DistrTypePsedo = 'OVM_F10' AND @PSEDO = 'DEPO_OVM_F10_CL'
		OR d.DistrTypePsedo = 'OVM_F01' AND @PSEDO = 'DEPO_OVM_F01'
		OR d.DistrTypePsedo = 'OVM_F01' AND @PSEDO = 'DEPO_OVM_F01_CL'
		OR d.DistrTypePsedo = 'LOCAL' AND @PSEDO = 'DEPO_ALL'
		OR d.DistrTypePsedo = 'OVS_5' AND @PSEDO = 'DEPO_OVS_5'
		OR d.DistrTypePsedo = 'OVS_10' AND @PSEDO = 'DEPO_OVS_10'
		OR d.DistrTypePsedo = 'OVS_20' AND @PSEDO = 'DEPO_OVS_20'
		OR d.DistrTypePsedo = 'OVS_50' AND @PSEDO = 'DEPO_OVS_50'


	IF @TYPE = '3' AND (@PSEDO = 'ONLINE_EXP_CLIENT' OR @PSEDO = 'DEPO_ONLINE_EXP_CLIENT' OR @PSEDO = 'ONLINE_EXP' OR @PSEDO = 'DEPO_ONLINE_EXP')
	BEGIN
		SET @DCOEF = 1.1
		SET @DROUND = 2
		SET @NOTE = 0
	END
	ELSE IF @TYPE = 2 AND (@PSEDO = 'ONLINE_EXP_CLIENT' OR @PSEDO = 'DEPO_ONLINE_EXP_CLIENT' OR @PSEDO = 'ONLINE_EXP' OR @PSEDO = 'DEPO_ONLINE_EXP')
	BEGIN
		SET @DCOEF = 1
		SET @DROUND = 2
		SET @NOTE = 0
	END
	/*
	ELSE
	BEGIN
		SET @DCOEF = 1
		SET @DROUND = 2
		SET @NOTE = 0
	END*/

	SELECT DISTINCT
		SystemFullName /*+
			CASE
				WHEN @TYPE <> '1' THEN ''
				ELSE
					CASE @PSEDO 
						WHEN 'ONLINE' THEN ' ОВП'
						WHEN 'ONLINE2' THEN ' ОВПИ'
						WHEN 'ONLINE2_CLIENT' THEN ' ОВПИ'
						WHEN 'ONLINE3' THEN ' ОВК'
						WHEN 'ONLINE3_CLIENT' THEN ' ОВК'
						WHEN 'MOBILE' THEN ' Мобильная версия'
						WHEN 'ONLINE_EXP' THEN ' ОВП'
						WHEN 'ONLINE_EXP_CLIENT' THEN ' ОВП'
						WHEN 'OVM_1' THEN ' ОВМ (ОД 1)'
						WHEN 'OVM_1_CL' THEN ' ОВМ (ОД 1)'
						WHEN 'OVM_2' THEN ' ОВМ (ОД 2)'
						WHEN 'OVM_2_CL' THEN ' ОВМ (ОД 2)'
						WHEN 'DEPO_ONLINE' THEN ' ОВП'
						WHEN 'DEPO_ONLINE2' THEN ' ОВПИ'
						WHEN 'DEPO_ONLINE2_CLIENT' THEN ' ОВПИ'
						WHEN 'DEPO_ONLINE3' THEN ' ОВК'
						WHEN 'DEPO_ONLINE3_CLIENT' THEN ' ОВК'
						WHEN 'DEPO_ONLINE_EXP' THEN ' ОВП'
						WHEN 'DEPO_ONLINE_EXP_CLIENT' THEN ' ОВП'
						WHEN 'DEPO_OVM_1' THEN ' ОВМ (ОД 1)'
						WHEN 'DEPO_OVM_1_CL' THEN ' ОВМ (ОД 1)'
						WHEN 'DEPO_OVM_2' THEN ' ОВМ (ОД 2)'
						WHEN 'DEPO_OVM_2_CL' THEN ' ОВМ (ОД 2)'
						ELSE ''
					END
				END */AS SystemName,
				SystemGroupID, SystemGroupOrder, /*SystemName,*/ SystemDocNumber, SystemVolume, SystemOrder, SystemNote,
		BoldStart, BoldLength,
		SystemReg,
		SystemGroupName,
		CASE @PSEDO
			WHEN 'ONLINE' THEN SystemPeriodicityOnline
			WHEN 'ONLINE2' THEN SystemPeriodicityOnline
			WHEN 'ONLINE2_CLIENT' THEN SystemPeriodicityOnline
			WHEN 'ONLINE3' THEN SystemPeriodicityOnline
			WHEN 'ONLINE_EXP' THEN SystemPeriodicityOnline
			WHEN 'ONLINE_EXP_CLIENT' THEN SystemPeriodicityOnline
			WHEN 'OVM_1' THEN SystemPeriodicityOnline
			WHEN 'OVM_1_CL' THEN SystemPeriodicityOnline
			WHEN 'OVM_2' THEN SystemPeriodicityOnline
			WHEN 'OVM_2_CL' THEN SystemPeriodicityOnline
			WHEN 'OVM_3' THEN SystemPeriodicityOnline
			WHEN 'OVM_3_CL' THEN SystemPeriodicityOnline
			WHEN 'DEPO_ONLINE2' THEN SystemPeriodicityOnline
			WHEN 'DEPO_ONLINE3' THEN SystemPeriodicityOnline
			WHEN 'DEPO_ONLINE_EXP' THEN SystemPeriodicityOnline
			WHEN 'DEPO_OVM_1' THEN SystemPeriodicityOnline
			WHEN 'DEPO_OVM_2' THEN SystemPeriodicityOnline 
			WHEN 'DEPO_OVM_3' THEN SystemPeriodicityOnline 
			ELSE SystemPeriodicity
		END AS SystemPeriodicity,
		SystemMain, SystemPeriodicityOnline,
		SystemPrice,
		ROUND(SystemPrice * @TaxRate, 2) AS SystemPriceNDS,
		CASE WHEN SystemReg = 'ROS' THEN NULL ELSE SystemPrice * 3 END AS SystemDeliveryPrice,
		CASE WHEN SystemReg = 'ROS' THEN NULL ELSE ROUND(SystemPrice * @TaxRate, 2) * 3 END AS SystemDeliveryPriceNDS,
		SystemPriceMos,
		ROUND(SystemPriceMos * @TaxRate, 2) AS SystemPriceMosNDS,
		SystemPriceMos * 3 AS SystemDeliveryPriceMos,
		ROUND(SystemPriceMos * @TaxRate, 2) * 3 AS SystemDeliveryPriceMosNDS,
		SystemOnlineDelivery, ROUND(SystemOnlineDelivery * @TaxRate, 2) AS SystemOnlineDeliveryNDS
	FROM
		(
			SELECT
				(' ' + SystemPrefix + ' ' + SystemName + CASE @NOTE WHEN 1 THEN SystemPostfix ELSE '' END) AS SystemFullName,
				SystemPostfix AS SystemNote,
				LEN(' ' + SystemPrefix + ' ' + SystemName) + 1 AS BoldStart,
				LEN(SystemPostfix) AS BoldLength,
				SystemGroupID, SystemGroupOrder, SystemName, SystemReg, SystemDocNumber, SystemVolume, SystemOrder,
				SystemGroupName, SystemPeriodicity, SystemMain, SystemPeriodicityOnline,
				Round(@TotalCoef *
				CASE @PSEDO
					WHEN 'MOBILE' THEN
						CASE
							WHEN EXISTS
								(
									SELECT *
									FROM dbo.SystemComposite
									WHERE SystemID = ID_SYSTEM
								) THEN
									(
										SELECT SUM(SystemPriceMos)
										FROM
											dbo.SystemTable z
											INNER JOIN dbo.SystemComposite ON ID_COMPOSITE = z.SystemID
										WHERE ID_SYSTEM = a.SystemID
									)
							ELSE SystemPriceMos
						END
					WHEN 'ONLINE2' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					WHEN 'ONLINE_EXP' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					WHEN 'ONLINE3' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					WHEN 'OVM_1' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					WHEN 'OVM_2' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					WHEN 'OVM_3' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					ELSE
						CASE
							WHEN @PSEDO LIKE 'DEPO[_]%' THEN
								CASE
									WHEN SystemName = 'КонсультантЮрист' AND GETDATE() >= '20170601' AND GETDATE() < '20170701' THEN
										ROUND(4300 * @DCOEF, @DROUND)
									WHEN SystemReg IN ('SKBO', 'SKUO', 'SBOO', 'SKJP') AND @TYPE = '5' THEN
										ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.3 +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.3, @DROUND) < ROUND(SystemServicePrice * 1.3, @DROUND) * @DEPO THEN 10
												ELSE 0
											END
											, @DROUND)
									WHEN SystemReg IN ('SKUP', 'SBOP') AND @TYPE = '5' THEN
										ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.5 +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.5, @DROUND) < ROUND(SystemServicePrice * 1.5, @DROUND) * @DEPO THEN 10
												ELSE 0
											END
											, @DROUND)
									WHEN @PSEDO LIKE '%OVM[_]F%' AND SystemReg IN ('SKBO', 'SKJP', 'SKUP', 'SKUO', 'SBOP', 'SBOO') THEN
										ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.25 +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.25, @DROUND) < ROUND(SystemServicePrice * 1.25, @DROUND) * @DEPO THEN 10
												ELSE 0
											END
											, @DROUND)
									WHEN @PSEDO LIKE '%OVM[_]F%' AND SystemReg IN ('SKZO') THEN
										ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.3 +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * 1.3, @DROUND) < ROUND(SystemServicePrice * 1.3, @DROUND) * @DEPO THEN 10
												ELSE 0
											END
											, @DROUND)
									WHEN @PSEDO LIKE '%OVS%' AND SystemReg IN ('SKUP', 'SBOP') THEN
										ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * @DCOEF * 1.15 +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * @DCOEF * 1.15, @DROUND) < ROUND(SystemServicePrice * @DCOEF * 1.15, @DROUND) * @DEPO THEN 10
												ELSE 0
											END
											, @DROUND)
									ELSE
										ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * @DCOEF +
											CASE
												WHEN ROUND(ROUND(CEILING(CEILING(SystemServicePrice * @DEPO)/10.0) * 10, -1) * @DCOEF, @DROUND) < ROUND(SystemServicePrice * @DCOEF, @DROUND) * @DEPO THEN 10
												ELSE 0
											END
											, @DROUND)
								END
							ELSE
								CASE
									WHEN EXISTS
										(
											SELECT *
											FROM dbo.SystemComposite
											WHERE SystemID = ID_SYSTEM
										) THEN
											(
												SELECT SUM(ROUND(z.SystemServicePrice * @DCOEF, @DROUND))
												FROM
													dbo.SystemTable z
													INNER JOIN dbo.SystemComposite ON ID_COMPOSITE = z.SystemID
												WHERE ID_SYSTEM = a.SystemID
											)
									WHEN SystemReg IN ('SKBO', 'SKUO', 'SBOO', 'SKJP') AND @TYPE = '5' THEN ROUND(SystemServicePrice * 1.3, @DROUND)
									WHEN SystemReg IN ('SKUP', 'SBOP') AND @TYPE = '5' THEN ROUND(SystemServicePrice * 1.5, @DROUND)
									WHEN @PSEDO LIKE '%OVM[_]F%' AND SystemReg IN ('SKBO', 'SKJP', 'SKUP', 'SKUO', 'SBOP', 'SBOO') THEN ROUND(SystemServicePrice * 1.25, @DROUND)
									WHEN @PSEDO LIKE '%OVM[_]F%' AND SystemReg IN ('SKZO') THEN ROUND(SystemServicePrice * 1.3, @DROUND)
									WHEN @PSEDO LIKE '%OVS%' AND SystemReg IN ('SKUP', 'SBOP') THEN ROUND(SystemServicePrice * @DCOEF * 1.15, @DROUND)
									ELSE
										ROUND(SystemServicePrice * @DCOEF, @DROUND)
								END
						END
				END, 2) AS SystemPrice,
				Round(@TotalCoef *
				CASE @PSEDO
					WHEN 'MOBILE' THEN ROUND(SystemPriceMos * @DCOEF, @DROUND)
					WHEN 'ONLINE2' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
					WHEN 'ONLINE_EXP' THEN ROUND(SystemPriceOnline2 * @DCOEF, @DROUND)
				END, 2) AS SystemPriceMos,
				[dbo].[DefaultDeliveryPriceGet]() AS SystemOnlineDelivery
			FROM
			(
			    SELECT
			        SystemID, SystemName, SystemPrefix, a.SystemGroupID, SystemVolume, SystemDocNumber, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, SystemPeriodicityOnline, SystemPriceMos, SystemPriceOnline2, SystemPriceRec, IsExpired,
			        SystemGroupName, SystemGroupOrder,
			        [DistrTypeEnable] = c.ENABLE,
			        DistrTypeID, DistrTypeName, DistrTypeMainStr, DistrTypeCoefficient, DistrTypeStr, DistrTypeNet, DistrTypePrint, DistrTypePsedo, DistrTypeRound,
			        ID_PRICE,
			        [PriceEnable] = e.ENABLED
			    FROM dbo.SystemTable a
				INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
				INNER JOIN dbo.SystemDistrType c ON c.ID_SYSTEM = a.SystemID
				INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = c.ID_TYPE
				INNER JOIN dbo.SystemPrice e ON e.ID_SYSTEM = a.SystemID
				WHERE @ArchDate IS NULL

				UNION ALL

				SELECT
				    SystemID, SystemName, SystemPrefix, a.SystemGroupID, SystemVolume, SystemDocNumber, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, SystemPeriodicityOnline, SystemPriceMos, SystemPriceOnline2, SystemPriceRec, IsExpired,
			        SystemGroupName, SystemGroupOrder,
			        [DistrTypeEnable] = c.ENABLE,
			        DistrTypeID, DistrTypeName, DistrTypeMainStr, DistrTypeCoefficient, DistrTypeStr, DistrTypeNet, DistrTypePrint, DistrTypePsedo, DistrTypeRound,
			        ID_PRICE,
			        [PriceEnable] = e.ENABLED
			    FROM dbo.SystemHistoryTable a
				INNER JOIN dbo.SystemGroupHistoryTable b ON a.SystemGroupID = b.SystemGroupID
				INNER JOIN dbo.SystemDistrType c ON c.ID_SYSTEM = a.SystemID
				INNER JOIN dbo.DistrTypeTable d ON d.DistrTypeID = c.ID_TYPE
				INNER JOIN dbo.SystemPrice e ON e.ID_SYSTEM = a.SystemID
				WHERE a.PriceDate = @ArchDate AND b.GroupPriceDate = @ArchDate
			) AS A
			WHERE [DistrTypeEnable] = 1
				AND (a.IsExpired = 0 AND @ShowExpired = 0 OR @ShowExpired = 1)
				AND ([PriceEnable] = 1 OR @PSEDO = 'DEPO_ALL')
				AND ID_PRICE = CONVERT(INT, @TYPE)
					AND (
						DistrTypePsedo = @PSEDO
						OR DistrTypePsedo = 'ONLINE2' AND @PSEDO = 'ONLINE2_CLIENT'
						OR DistrTypePsedo = 'ONLINE3' AND @PSEDO = 'ONLINE3_CLIENT'
						OR DistrTypePsedo = 'OVM_1' AND @PSEDO = 'OVM_1_CL'
						OR DistrTypePsedo = 'OVM_2' AND @PSEDO = 'OVM_2_CL'
						OR DistrTypePsedo = 'OVM_3' AND @PSEDO = 'OVM_3_CL'
						OR DistrTypePsedo = 'OVM_F12' AND @PSEDO = 'OVM_F12_CL'
						OR DistrTypePsedo = 'OVM_F10' AND @PSEDO = 'OVM_F10_CL'
						OR DistrTypePsedo = 'OVM_F01' AND @PSEDO = 'OVM_F01_CL'
						OR DistrTypePsedo = 'ONLINE_EXP' AND @PSEDO = 'ONLINE_EXP_CLIENT'
						OR DistrTypePsedo = 'LOCAL' AND @PSEDO = 'DEPO_LOCAL'
						OR DistrTypePsedo = 'FLASH' AND @PSEDO = 'DEPO_FLASH'
						OR DistrTypePsedo = 'NET1' AND @PSEDO = 'DEPO_NET1'
						OR DistrTypePsedo = 'NET_SMALL' AND @PSEDO = 'DEPO_NET_SMALL'
						OR DistrTypePsedo = 'NET50' AND @PSEDO = 'DEPO_NET50'
						OR DistrTypePsedo = 'ONLINE_EXP' AND @PSEDO = 'DEPO_ONLINE_EXP'
						OR DistrTypePsedo = 'ONLINE2' AND @PSEDO = 'DEPO_ONLINE2'
						OR DistrTypePsedo = 'ONLINE3' AND @PSEDO = 'DEPO_ONLINE3'
						OR DistrTypePsedo = 'OVM_1' AND @PSEDO = 'DEPO_OVM_1'
						OR DistrTypePsedo = 'OVM_2' AND @PSEDO = 'DEPO_OVM_2'
						OR DistrTypePsedo = 'OVM_3' AND @PSEDO = 'DEPO_OVM_3'
						OR DistrTypePsedo = 'ONLINE_EXP' AND @PSEDO = 'DEPO_ONLINE_EXP_CLIENT'
						OR DistrTypePsedo = 'ONLINE2' AND @PSEDO = 'DEPO_ONLINE2_CLIENT'
						OR DistrTypePsedo = 'ONLINE3' AND @PSEDO = 'DEPO_ONLINE3_CLIENT'
						OR DistrTypePsedo = 'OVM_1' AND @PSEDO = 'DEPO_OVM_1_CL'
						OR DistrTypePsedo = 'OVM_2' AND @PSEDO = 'DEPO_OVM_2_CL'
						OR DistrTypePsedo = 'OVM_3' AND @PSEDO = 'DEPO_OVM_3_CL'
						OR DistrTypePsedo = 'OVM_F12' AND @PSEDO = 'DEPO_OVM_F12'
						OR DistrTypePsedo = 'OVM_F12' AND @PSEDO = 'DEPO_OVM_F12_CL'
						OR DistrTypePsedo = 'OVM_F10' AND @PSEDO = 'DEPO_OVM_F10'
						OR DistrTypePsedo = 'OVM_F10' AND @PSEDO = 'DEPO_OVM_F10_CL'
						OR DistrTypePsedo = 'OVM_F01' AND @PSEDO = 'DEPO_OVM_F01'
						OR DistrTypePsedo = 'OVM_F01' AND @PSEDO = 'DEPO_OVM_F01_CL'
						OR DistrTypePsedo = 'OVS_5' AND @PSEDO = 'DEPO_OVS_5'
						OR DistrTypePsedo = 'OVS_10' AND @PSEDO = 'DEPO_OVS_10'
						OR DistrTypePsedo = 'OVS_20' AND @PSEDO = 'DEPO_OVS_20'
						OR DistrTypePsedo = 'OVS_50' AND @PSEDO = 'DEPO_OVS_50'
						OR @PSEDO = 'DEPO_ALL'
					)

		) AS a
    ORDER BY
		SystemMain DESC,
		/*
		CASE @PSEDO
			WHEN 'ONLINE' THEN SystemMain
			WHEN 'ONLINE2' THEN SystemMain
			WHEN 'ONLINE3' THEN SystemMain
			WHEN 'MOBILE' THEN SystemMain
			ELSE NULL
		END DESC,*/
		SystemGroupOrder, SystemOrder
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_PRICE_LIST_SELECT] TO DBCount;
GRANT EXECUTE ON [dbo].[SYSTEM_PRICE_LIST_SELECT] TO DBPrice;
GRANT EXECUTE ON [dbo].[SYSTEM_PRICE_LIST_SELECT] TO DBPriceReader;
GO
