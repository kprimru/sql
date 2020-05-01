USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_EXPORT_SELECT]
	@Depo	Bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Result Xml;

	IF @Depo = 0
		SET @Result =
			(
				SELECT
					[SYS]	= SystemReg,
					[PRICE]	= SystemServicePrice
				FROM dbo.SystemTable a
				INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
				WHERE SystemReg IS NOT NULL
				ORDER BY SystemGroupOrder, SystemOrder
				FOR XML RAW('ITEM'), ROOT('ROOT'), TYPE
			)
	ELSE BEGIN
		DECLARE @Res TABLE
		(
			SystemName					VarChar(1024),
			SystemGroupId				Int,
			SystemGroupOrder			Int,
			SystemDocNumber				Int,
			SystemVolume				Int,
			SystemOrder					Int,
			SystemNote					VarChar(1024),
			BoldStart					Int,
			BoldLength					Int,
			SystemReg					VarChar(100),
			SystemGroupName				VarChar(256),
			SystemPeriodicity			VarChar(256),
			SystemMain					Bit,
			SystemPeriodicityOnline		VarChar(256),
			SystemPrice					Money,
			SystemPriceNDS				Money,
			SystemDeliveryPrice			Money,
			SystemDeliveryPPriceNDS		Money,
			SYstemPriceMos				Money,
			SystemPriceMosNDS			Money,
			SystemDeliveryPriceMos		Money,
			SystemDelieryPriceMosNSD	Money,
			SystemOnlineDelivery		Money,
			SystemOnlineDeliveryNDS		Money
		);

		INSERT INTO @Res
		EXEC dbo.SYSTEM_PRICE_LIST_SELECT 'DEPO_ALL'

		SET @Result =
			(
				SELECT
					[SYS]	= SystemReg,
					[PRICE]	= SystemPrice
				FROM @Res
				WHERE SystemReg IS NOT NULL
				ORDER BY SystemGroupOrder, SystemOrder
				FOR XML RAW('ITEM'), ROOT('ROOT'), TYPE
			)
	END;

	SELECT [Data] = Cast(@Result AS NVarChar(Max));
END
GRANT EXECUTE ON [dbo].[PRICE_EXPORT_SELECT] TO DBCount;
GRANT EXECUTE ON [dbo].[PRICE_EXPORT_SELECT] TO DBPrice;
GRANT EXECUTE ON [dbo].[PRICE_EXPORT_SELECT] TO DBPriceReader;
GO