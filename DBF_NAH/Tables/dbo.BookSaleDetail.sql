USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookSaleDetail]
(
        [ID]          bigint     Identity(1,1)   NOT NULL,
        [ID_SALE]     bigint                     NOT NULL,
        [ID_TAX]      SmallInt                   NOT NULL,
        [S_ALL]       Money                      NOT NULL,
        [S_NDS]       Money                      NOT NULL,
        [S_BEZ_NDS]   Money                      NOT NULL,
        CONSTRAINT [PK_dbo.BookSaleDetail] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.BookSaleDetail(ID_SALE)_dbo.BookSale(ID)] FOREIGN KEY  ([ID_SALE]) REFERENCES [dbo].[BookSale] ([ID]),
        CONSTRAINT [FK_dbo.BookSaleDetail(ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.BookSaleDetail(ID_SALE,ID_TAX)] ON [dbo].[BookSaleDetail] ([ID_SALE] ASC, [ID_TAX] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.BookSaleDetail(ID_TAX)+(ID_SALE,S_NDS)] ON [dbo].[BookSaleDetail] ([ID_TAX] ASC) INCLUDE ([ID_SALE], [S_NDS]);
GO
