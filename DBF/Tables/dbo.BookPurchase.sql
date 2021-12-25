USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookPurchase]
(
        [ID]              bigint           Identity(1,1)   NOT NULL,
        [ID_ORG]          SmallInt                         NOT NULL,
        [ID_AVANS]        Int                              NOT NULL,
        [ID_INVOICE]      Int                              NOT NULL,
        [CODE]            NVarChar(32)                     NOT NULL,
        [NUM]             Int                                  NULL,
        [DATE]            SmallDateTime                        NULL,
        [NAME]            NVarChar(1024)                       NULL,
        [INN]             NVarChar(128)                        NULL,
        [KPP]             NVarChar(128)                        NULL,
        [IN_NUM]          NVarChar(32)                         NULL,
        [IN_DATE]         SmallDateTime                        NULL,
        [PURCHASE_DATE]   SmallDateTime                        NULL,
        CONSTRAINT [PK_dbo.BookPurchase] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.BookPurchase(ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.BookPurchase(ID_AVANS)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([ID_AVANS]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID]),
        CONSTRAINT [FK_dbo.BookPurchase(ID_INVOICE)_dbo.InvoiceSaleTable(INS_ID)] FOREIGN KEY  ([ID_INVOICE]) REFERENCES [dbo].[InvoiceSaleTable] ([INS_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.BookPurchase(ID_INVOICE,ID_AVANS)] ON [dbo].[BookPurchase] ([ID_INVOICE] ASC, [ID_AVANS] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BookPurchase(ID_AVANS,ID_INVOICE)+(ID)] ON [dbo].[BookPurchase] ([ID_AVANS] ASC, [ID_INVOICE] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.BookPurchase(ID_ORG,PURCHASE_DATE)+(ID,ID_INVOICE)] ON [dbo].[BookPurchase] ([ID_ORG] ASC, [PURCHASE_DATE] ASC) INCLUDE ([ID], [ID_INVOICE]);
GO
