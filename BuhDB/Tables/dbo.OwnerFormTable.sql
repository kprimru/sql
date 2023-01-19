USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OwnerFormTable]
(
        [OwnerFormID]          Int            Identity(1,1)   NOT NULL,
        [OwnerFormShortName]   VarChar(20)                    NOT NULL,
        [OwnerFormName]        VarChar(200)                   NOT NULL,
        CONSTRAINT [PK_dbo.OwnerFormTable] PRIMARY KEY CLUSTERED ([OwnerFormID])
);
GO
GRANT DELETE ON [dbo].[OwnerFormTable] TO DBAdministrator;
GRANT INSERT ON [dbo].[OwnerFormTable] TO DBAdministrator;
GRANT SELECT ON [dbo].[OwnerFormTable] TO DBAdministrator;
GRANT UPDATE ON [dbo].[OwnerFormTable] TO DBAdministrator;
GRANT DELETE ON [dbo].[OwnerFormTable] TO DBCount;
GRANT INSERT ON [dbo].[OwnerFormTable] TO DBCount;
GRANT SELECT ON [dbo].[OwnerFormTable] TO DBCount;
GRANT UPDATE ON [dbo].[OwnerFormTable] TO DBCount;
GRANT SELECT ON [dbo].[OwnerFormTable] TO DBPrice;
GRANT SELECT ON [dbo].[OwnerFormTable] TO DBPriceReader;
GO
