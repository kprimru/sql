USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[PriceSystem]
(
        [PS_ID]          bigint     Identity(1,1)   NOT NULL,
        [PS_ID_PERIOD]   SmallInt                   NOT NULL,
        [PS_ID_PRICE]    SmallInt                   NOT NULL,
        [PS_ID_TYPE]     SmallInt                   NOT NULL,
        [PS_ID_SYSTEM]   SmallInt                   NOT NULL,
        [PS_ID_NET]      SmallInt                   NOT NULL,
        [PS_PRICE]       Money                      NOT NULL,
        CONSTRAINT [PK_Price.PriceSystem] PRIMARY KEY CLUSTERED ([PS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Price.PriceSystem(PS_ID_PERIOD,PS_ID_PRICE,PS_ID_TYPE,PS_ID_NET)+(PS_ID_SYSTEM,PS_PRICE)] ON [Price].[PriceSystem] ([PS_ID_PERIOD] ASC, [PS_ID_PRICE] ASC, [PS_ID_TYPE] ASC, [PS_ID_NET] ASC) INCLUDE ([PS_ID_SYSTEM], [PS_PRICE]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_Price.PriceSystem(PS_ID_PERIOD,PS_ID_SYSTEM,PS_ID_PRICE,PS_ID_TYPE,PS_ID_NET)] ON [Price].[PriceSystem] ([PS_ID_PERIOD] ASC, [PS_ID_SYSTEM] ASC, [PS_ID_PRICE] ASC, [PS_ID_TYPE] ASC, [PS_ID_NET] ASC);
GO
