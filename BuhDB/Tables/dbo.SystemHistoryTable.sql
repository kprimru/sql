USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemHistoryTable]
(
        [ID]                        Int             Identity(1,1)   NOT NULL,
        [SystemID]                  Int                             NOT NULL,
        [SystemName]                VarChar(500)                    NOT NULL,
        [SystemPrefix]              VarChar(10)                         NULL,
        [SystemGroupID]             Int                             NOT NULL,
        [SystemVolume]              Int                                 NULL,
        [SystemDocNumber]           Int                                 NULL,
        [SystemPeriodicity]         VarChar(50)                         NULL,
        [SystemServicePrice]        Money                           NOT NULL,
        [SystemOrder]               Int                             NOT NULL,
        [SaleObjectID]              Int                             NOT NULL,
        [SystemPrint]               Bit                             NOT NULL,
        [SystemPostfix]             VarChar(2000)                       NULL,
        [SystemReg]                 VarChar(20)                         NULL,
        [SystemMain]                Bit                                 NULL,
        [SystemPeriodicityOnline]   VarChar(50)                         NULL,
        [SystemPriceMos]            Money                               NULL,
        [SystemPriceOnline2]        Money                               NULL,
        [SystemPriceRec]            Money                               NULL,
        [IsExpired]                 Bit                             NOT NULL,
        [PriceDate]                 VarChar(20)                     NOT NULL,
        CONSTRAINT [PK_dbo.SystemHistoryTable] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.SystemHistoryTable(PriceDate)+INCL] ON [dbo].[SystemHistoryTable] ([PriceDate] ASC) INCLUDE ([ID], [SystemID], [SystemName], [SystemPrefix], [SystemGroupID], [SystemVolume], [SystemDocNumber], [SystemServicePrice], [SystemOrder], [SystemPrint]);
GO
GRANT DELETE ON [dbo].[SystemHistoryTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[SystemHistoryTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemHistoryTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SystemHistoryTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemHistoryTable] TO DBCount;
GRANT DELETE ON [dbo].[SystemHistoryTable] TO DBPrice;
GRANT INSERT ON [dbo].[SystemHistoryTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemHistoryTable] TO DBPrice;
GRANT UPDATE ON [dbo].[SystemHistoryTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemHistoryTable] TO DBPriceReader;
GO
