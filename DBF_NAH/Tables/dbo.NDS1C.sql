USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NDS1C]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_ORG]      SmallInt              NOT NULL,
        [ID_TAX]      SmallInt              NOT NULL,
        [ID_PERIOD]   SmallInt              NOT NULL,
        CONSTRAINT [PK_dbo.NDS1C] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.NDS1C(ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.NDS1C(ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.NDS1C(ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID])
);GO
