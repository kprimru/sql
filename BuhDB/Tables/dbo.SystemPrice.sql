USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemPrice]
(
        [ID]          Int   Identity(1,1)   NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        [ID_PRICE]    Int                   NOT NULL,
        [ENABLED]     Bit                   NOT NULL,
        CONSTRAINT [PK_dbo.SystemPrice] PRIMARY KEY CLUSTERED ([ID])
);GO
GRANT DELETE ON [dbo].[SystemPrice] TO DBAdministrator;
GRANT INSERT ON [dbo].[SystemPrice] TO DBAdministrator;
GRANT SELECT ON [dbo].[SystemPrice] TO DBAdministrator;
GRANT UPDATE ON [dbo].[SystemPrice] TO DBAdministrator;
GRANT DELETE ON [dbo].[SystemPrice] TO DBCount;
GRANT INSERT ON [dbo].[SystemPrice] TO DBCount;
GRANT SELECT ON [dbo].[SystemPrice] TO DBCount;
GRANT UPDATE ON [dbo].[SystemPrice] TO DBCount;
GRANT DELETE ON [dbo].[SystemPrice] TO DBPrice;
GRANT INSERT ON [dbo].[SystemPrice] TO DBPrice;
GRANT SELECT ON [dbo].[SystemPrice] TO DBPrice;
GRANT UPDATE ON [dbo].[SystemPrice] TO DBPrice;
GRANT DELETE ON [dbo].[SystemPrice] TO DBPriceReader;
GRANT INSERT ON [dbo].[SystemPrice] TO DBPriceReader;
GRANT SELECT ON [dbo].[SystemPrice] TO DBPriceReader;
GRANT UPDATE ON [dbo].[SystemPrice] TO DBPriceReader;
GO
