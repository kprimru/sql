USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerTable]
(
        [CustomerID]          Int            Identity(1,1)   NOT NULL,
        [CustomerName]        VarChar(150)                   NOT NULL,
        [OwnerFormID]         Int                                NULL,
        [CustomerShortName]   VarChar(50)                    NOT NULL,
        [StreetID]            Int                                NULL,
        [CustomerHome]        VarChar(50)                        NULL,
        [CustomerPhone]       VarChar(100)                       NULL,
        [BankID]              Int                                NULL,
        [CustomerCalc]        VarChar(50)                        NULL,
        [CustomerPurchaser]   VarChar(100)                       NULL,
        [CustomerCorrCount]   VarChar(50)                        NULL,
        [CustomerINN]         VarChar(50)                        NULL,
        [Recieve]             VarChar(150)                       NULL,
        [RecieveAdress]       VarChar(200)                       NULL,
        [CustomerUrAdress]    VarChar(250)                       NULL,
        [CustomerBik]         VarChar(50)                        NULL,
        CONSTRAINT [PK_dbo.CustomerTable] PRIMARY KEY CLUSTERED ([CustomerID]),
        CONSTRAINT [FK_dbo.CustomerTable(OwnerFormID)_dbo.OwnerFormTable(OwnerFormID)] FOREIGN KEY  ([OwnerFormID]) REFERENCES [dbo].[OwnerFormTable] ([OwnerFormID]),
        CONSTRAINT [FK_dbo.CustomerTable(BankID)_dbo.BankTable(BankID)] FOREIGN KEY  ([BankID]) REFERENCES [dbo].[BankTable] ([BankID]),
        CONSTRAINT [FK_dbo.CustomerTable(StreetID)_dbo.StreetTable(StreetID)] FOREIGN KEY  ([StreetID]) REFERENCES [dbo].[StreetTable] ([StreetID])
);GO
GRANT DELETE ON [dbo].[CustomerTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[CustomerTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[CustomerTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[CustomerTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[CustomerTable] TO DBCount;
GRANT INSERT ON [dbo].[CustomerTable] TO DBCount;
GRANT SELECT ON [dbo].[CustomerTable] TO DBCount;
GRANT UPDATE ON [dbo].[CustomerTable] TO DBCount;
GO
