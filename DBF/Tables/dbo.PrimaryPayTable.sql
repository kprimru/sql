USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrimaryPayTable]
(
        [PRP_ID]            Int             Identity(1,1)   NOT NULL,
        [PRP_ID_CLIENT]     Int                                 NULL,
        [PRP_ID_DISTR]      Int                             NOT NULL,
        [PRP_DATE]          SmallDateTime                       NULL,
        [PRP_PRICE]         Money                               NULL,
        [PRP_TAX_PRICE]     Money                               NULL,
        [PRP_TOTAL_PRICE]   Money                               NULL,
        [PRP_DOC]           VarChar(50)                         NULL,
        [PRP_ID_TAX]        SmallInt                            NULL,
        [PRP_ID_INVOICE]    Int                                 NULL,
        [PRP_COMMENT]       VarChar(250)                        NULL,
        [PRP_ID_ORG]        SmallInt                            NULL,
        CONSTRAINT [PK_dbo.PrimaryPayTable] PRIMARY KEY NONCLUSTERED ([PRP_ID]),
        CONSTRAINT [FK_dbo.PrimaryPayTable(PRP_ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([PRP_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.PrimaryPayTable(PRP_ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([PRP_ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID]),
        CONSTRAINT [FK_dbo.PrimaryPayTable(PRP_ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([PRP_ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID]),
        CONSTRAINT [FK_dbo.PrimaryPayTable(PRP_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([PRP_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.PrimaryPayTable(PRP_ID_DISTR)] ON [dbo].[PrimaryPayTable] ([PRP_ID_DISTR] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PrimaryPayTable(PRP_ID_CLIENT)] ON [dbo].[PrimaryPayTable] ([PRP_ID_CLIENT] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.PrimaryPayTable(PRP_ID_INVOICE)+(PRP_ID_DISTR)] ON [dbo].[PrimaryPayTable] ([PRP_ID_INVOICE] ASC) INCLUDE ([PRP_ID_DISTR]);
GO
