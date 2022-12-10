USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProviderTable]
(
        [ProviderID]                    Int            Identity(1,1)   NOT NULL,
        [ProviderName]                  VarChar(150)                   NOT NULL,
        [ProviderFullName]              VarChar(250)                       NULL,
        [OwnerFormID]                   Int                            NOT NULL,
        [ProviderShortName]             VarChar(50)                    NOT NULL,
        [ProviderINN]                   VarChar(100)                   NOT NULL,
        [StreetID]                      Int                            NOT NULL,
        [ProviderHome]                  VarChar(50)                    NOT NULL,
        [ProviderPhone]                 VarChar(100)                   NOT NULL,
        [ProviderCalc]                  VarChar(50)                    NOT NULL,
        [BankID]                        Int                            NOT NULL,
        [ProviderCorrCount]             VarChar(50)                    NOT NULL,
        [ProviderBuh]                   VarChar(100)                   NOT NULL,
        [ProviderSite]                  VarChar(200)                   NOT NULL,
        [ProviderDirector]              VarChar(200)                   NOT NULL,
        [ProviderDirectorRod]           VarChar(200)                   NOT NULL,
        [ProviderSender]                VarChar(150)                       NULL,
        [ProviderSenderAdress]          VarChar(250)                       NULL,
        [ProviderDistributor]           VarChar(50)                        NULL,
        [ProviderLogo]                  varbinary                          NULL,
        [ProviderDirectorPosition]      VarChar(100)                       NULL,
        [ProviderDirectorPositionRod]   VarChar(100)                       NULL,
        [ProviderPurpose]               VarChar(256)                       NULL,
        CONSTRAINT [PK_dbo.ProviderTable] PRIMARY KEY CLUSTERED ([ProviderID]),
        CONSTRAINT [FK_dbo.ProviderTable(OwnerFormID)_dbo.OwnerFormTable(OwnerFormID)] FOREIGN KEY  ([OwnerFormID]) REFERENCES [dbo].[OwnerFormTable] ([OwnerFormID]),
        CONSTRAINT [FK_dbo.ProviderTable(BankID)_dbo.BankTable(BankID)] FOREIGN KEY  ([BankID]) REFERENCES [dbo].[BankTable] ([BankID]),
        CONSTRAINT [FK_dbo.ProviderTable(StreetID)_dbo.StreetTable(StreetID)] FOREIGN KEY  ([StreetID]) REFERENCES [dbo].[StreetTable] ([StreetID])
);GO
GRANT DELETE ON [dbo].[ProviderTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[ProviderTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[ProviderTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[ProviderTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[ProviderTable] TO DBCount;
GRANT INSERT ON [dbo].[ProviderTable] TO DBCount;
GRANT SELECT ON [dbo].[ProviderTable] TO DBCount;
GRANT UPDATE ON [dbo].[ProviderTable] TO DBCount;
GRANT SELECT ON [dbo].[ProviderTable] TO DBPrice;
GRANT SELECT ON [dbo].[ProviderTable] TO DBPriceReader;
GO
