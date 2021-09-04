USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTable]
(
        [SystemID]                  Int             Identity(1,1)   NOT NULL,
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
        CONSTRAINT [PK_dbo.SystemTable] PRIMARY KEY CLUSTERED ([SystemID]),
        CONSTRAINT [FK_dbo.SystemTable(SaleObjectID)_dbo.SaleObjectTable(SaleObjectID)] FOREIGN KEY  ([SaleObjectID]) REFERENCES [dbo].[SaleObjectTable] ([SaleObjectID]),
        CONSTRAINT [FK_dbo.SystemTable(SystemGroupID)_dbo.SystemGroupTable(SystemGroupID)] FOREIGN KEY  ([SystemGroupID]) REFERENCES [dbo].[SystemGroupTable] ([SystemGroupID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemTable(SystemName)] ON [dbo].[SystemTable] ([SystemName] ASC);
GO
GRANT DELETE ON [dbo].[SystemTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[SystemTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SystemTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemTable] TO DBCount;
GRANT DELETE ON [dbo].[SystemTable] TO DBPrice;
GRANT INSERT ON [dbo].[SystemTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemTable] TO DBPrice;
GRANT UPDATE ON [dbo].[SystemTable] TO DBPrice;
GRANT SELECT ON [dbo].[SystemTable] TO DBPriceReader;
GO
