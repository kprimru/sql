USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookSale]
(
        [ID]           bigint           Identity(1,1)   NOT NULL,
        [ID_ORG]       SmallInt                         NOT NULL,
        [ID_INVOICE]   Int                              NOT NULL,
        [CODE]         NVarChar(32)                     NOT NULL,
        [NUM]          Int                              NOT NULL,
        [DATE]         SmallDateTime                    NOT NULL,
        [NAME]         NVarChar(1024)                   NOT NULL,
        [INN]          NVarChar(128)                    NOT NULL,
        [KPP]          NVarChar(128)                    NOT NULL,
        [IN_NUM]       NVarChar(32)                         NULL,
        [IN_DATE]      SmallDateTime                        NULL,
        CONSTRAINT [PK_dbo.BookSale] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.BookSale(ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID]),
        CONSTRAINT [FK_dbo.BookSale(ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.BookSale(ID_INVOICE)] ON [dbo].[BookSale] ([ID_INVOICE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BookSale(DATE)+(ID_INVOICE)] ON [dbo].[BookSale] ([DATE] ASC) INCLUDE ([ID_INVOICE]);
CREATE NONCLUSTERED INDEX [IX_dbo.BookSale(ID_ORG,CODE,DATE)+(ID,ID_INVOICE)] ON [dbo].[BookSale] ([ID_ORG] ASC, [CODE] ASC, [DATE] ASC) INCLUDE ([ID], [ID_INVOICE]);
GO
