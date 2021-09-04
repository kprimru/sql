USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceSystemTable]
(
        [PS_ID]          Int        Identity(1,1)   NOT NULL,
        [PS_ID_PERIOD]   SmallInt                   NOT NULL,
        [PS_ID_TYPE]     SmallInt                   NOT NULL,
        [PS_ID_SYSTEM]   SmallInt                       NULL,
        [PS_ID_PGD]      SmallInt                       NULL,
        [PS_PRICE]       Money                          NULL,
        CONSTRAINT [PK_dbo.PriceSystemTable] PRIMARY KEY NONCLUSTERED ([PS_ID]),
        CONSTRAINT [FK_dbo.PriceSystemTable(PS_ID_TYPE)_dbo.PriceTypeTable(PT_ID)] FOREIGN KEY  ([PS_ID_TYPE]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID]),
        CONSTRAINT [FK_dbo.PriceSystemTable(PS_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([PS_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.PriceSystemTable(PS_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([PS_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UQ_dbo.PriceSystemTable()] ON [dbo].[PriceSystemTable] ([PS_ID_PERIOD] ASC, [PS_ID_SYSTEM] ASC, [PS_ID_TYPE] ASC, [PS_ID_PGD] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PriceSystemTable(PS_ID_PERIOD,PS_ID_TYPE)+(PS_ID_SYSTEM,PS_PRICE)] ON [dbo].[PriceSystemTable] ([PS_ID_PERIOD] ASC, [PS_ID_TYPE] ASC) INCLUDE ([PS_ID_SYSTEM], [PS_PRICE]);
CREATE NONCLUSTERED INDEX [IX_dbo.PriceSystemTable(PS_ID_SYSTEM,PS_ID_PERIOD,PS_PRICE,PS_ID_TYPE)] ON [dbo].[PriceSystemTable] ([PS_ID_SYSTEM] ASC, [PS_ID_PERIOD] ASC, [PS_PRICE] ASC, [PS_ID_TYPE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PriceSystemTable(PS_ID_TYPE,PS_PRICE)+(PS_ID_PERIOD,PS_ID_SYSTEM)] ON [dbo].[PriceSystemTable] ([PS_ID_TYPE] ASC, [PS_PRICE] ASC) INCLUDE ([PS_ID_PERIOD], [PS_ID_SYSTEM]);
GO
