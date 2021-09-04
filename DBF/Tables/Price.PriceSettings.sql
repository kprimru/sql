USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[PriceSettings]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_PRICE]      SmallInt              NOT NULL,
        [ID_SYS_TYPE]   SmallInt              NOT NULL,
        [ID_NET_TYPE]   SmallInt              NOT NULL,
        [INDEXING]      Bit                   NOT NULL,
        CONSTRAINT [PK_Price.PriceSettings] PRIMARY KEY CLUSTERED ([ID])
);GO
