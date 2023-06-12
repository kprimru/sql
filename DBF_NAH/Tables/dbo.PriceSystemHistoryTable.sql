USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceSystemHistoryTable]
(
        [PSH_ID]          Int        Identity(1,1)   NOT NULL,
        [PSH_ID_PERIOD]   SmallInt                   NOT NULL,
        [PSH_ID_SYSTEM]   SmallInt                   NOT NULL,
        [PSH_DOC_COUNT]   bigint                     NOT NULL,
        CONSTRAINT [PK_dbo.PriceSystemHistoryTable] PRIMARY KEY NONCLUSTERED ([PSH_ID]),
        CONSTRAINT [FK_dbo.PriceSystemHistoryTable(PSH_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([PSH_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_dbo.PriceSystemHistoryTable(PSH_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([PSH_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.PriceSystemHistoryTable(PSH_ID_PERIOD,PSH_ID_SYSTEM)] ON [dbo].[PriceSystemHistoryTable] ([PSH_ID_PERIOD] ASC, [PSH_ID_SYSTEM] ASC);
GO
