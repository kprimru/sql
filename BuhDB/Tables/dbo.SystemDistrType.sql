USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemDistrType]
(
        [ID]          Int   Identity(1,1)   NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        [ID_TYPE]     Int                   NOT NULL,
        [ENABLE]      Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.SystemDistrType] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemDistrType(ID_SYSTEM,ID_TYPE)] ON [dbo].[SystemDistrType] ([ID_SYSTEM] ASC, [ID_TYPE] ASC);
GO
GRANT DELETE ON [dbo].[SystemDistrType] TO DBAdministrator;
GRANT INSERT ON [dbo].[SystemDistrType] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemDistrType] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SystemDistrType] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemDistrType] TO DBCount;
GRANT DELETE ON [dbo].[SystemDistrType] TO DBPrice;
GRANT INSERT ON [dbo].[SystemDistrType] TO DBPrice;
GRANT SELECT ON [dbo].[SystemDistrType] TO DBPrice;
GRANT UPDATE ON [dbo].[SystemDistrType] TO DBPrice;
GRANT SELECT ON [dbo].[SystemDistrType] TO DBPriceReader;
GO
