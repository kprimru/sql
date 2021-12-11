USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[OfferOther]
(
        [ID]     UniqueIdentifier      NOT NULL,
        [NOTE]   varbinary             NOT NULL,
        CONSTRAINT [PK_Price.OfferOther] PRIMARY KEY CLUSTERED ([ID])
);
GO
