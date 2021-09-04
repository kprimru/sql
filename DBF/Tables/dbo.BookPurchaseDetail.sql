USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookPurchaseDetail]
(
        [ID]            bigint     Identity(1,1)   NOT NULL,
        [ID_PURCHASE]   bigint                     NOT NULL,
        [ID_TAX]        SmallInt                   NOT NULL,
        [S_ALL]         Money                      NOT NULL,
        [S_NDS]         Money                      NOT NULL,
        [S_BEZ_NDS]     Money                      NOT NULL,
        CONSTRAINT [PK_dbo.BookPurchaseDetail] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.BookPurchaseDetail(ID_PURCHASE)_dbo.BookPurchase(ID)] FOREIGN KEY  ([ID_PURCHASE]) REFERENCES [dbo].[BookPurchase] ([ID]),
        CONSTRAINT [FK_dbo.BookPurchaseDetail(ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.BookPurchaseDetail(ID_PURCHASE,ID_TAX)] ON [dbo].[BookPurchaseDetail] ([ID_PURCHASE] ASC, [ID_TAX] ASC);
GO
