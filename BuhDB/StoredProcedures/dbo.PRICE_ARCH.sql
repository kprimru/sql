USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PRICE_ARCH]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SystemHistoryTable(SystemID, SystemName, SystemPrefix, SystemGroupID, SystemVolume, SystemDocNumber, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, SystemPeriodicityOnline, SystemPriceMos, SystemPriceOnline2, SystemPriceRec, IsExpired, PriceDate)
    SELECT SystemID, SystemName, SystemPrefix, SystemGroupID, SystemVolume, SystemDocNumber, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, SystemPeriodicityOnline, SystemPriceMos, SystemPriceOnline2, SystemPriceRec, IsExpired, CONVERT(VARCHAR(20), GETDATE(), 112)
    FROM SystemTable

    INSERT INTO SystemGroupHistoryTable(SystemGroupID, SystemGroupName, SystemGroupOrder, GroupPriceDate)
    SELECT SystemGroupID, SystemGroupName, SystemGroupOrder, CONVERT(VARCHAR(20), GETDATE(), 112)
    FROM SystemGroupTable
END
GO
