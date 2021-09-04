USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceType]
(
        [ID]     Int           Identity(1,1)   NOT NULL,
        [NAME]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.PriceType] PRIMARY KEY CLUSTERED ([ID])
);GO
GRANT DELETE ON [dbo].[PriceType] TO DBAdministrator;
GRANT INSERT ON [dbo].[PriceType] TO DBAdministrator;
GRANT SELECT ON [dbo].[PriceType] TO DBAdministrator;
GRANT UPDATE ON [dbo].[PriceType] TO DBAdministrator;
GRANT DELETE ON [dbo].[PriceType] TO DBCount;
GRANT INSERT ON [dbo].[PriceType] TO DBCount;
GRANT SELECT ON [dbo].[PriceType] TO DBCount;
GRANT UPDATE ON [dbo].[PriceType] TO DBCount;
GRANT DELETE ON [dbo].[PriceType] TO DBPrice;
GRANT INSERT ON [dbo].[PriceType] TO DBPrice;
GRANT SELECT ON [dbo].[PriceType] TO DBPrice;
GRANT UPDATE ON [dbo].[PriceType] TO DBPrice;
GRANT DELETE ON [dbo].[PriceType] TO DBPriceReader;
GRANT INSERT ON [dbo].[PriceType] TO DBPriceReader;
GRANT SELECT ON [dbo].[PriceType] TO DBPriceReader;
GRANT UPDATE ON [dbo].[PriceType] TO DBPriceReader;
GO
