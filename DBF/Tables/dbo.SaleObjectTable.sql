USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SaleObjectTable]
(
        [SO_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [SO_NAME]       VarChar(50)                    NOT NULL,
        [SO_ID_TAX]     SmallInt                       NOT NULL,
        [SO_BILL_STR]   VarChar(50)                        NULL,
        [SO_INV_STR]    VarChar(50)                        NULL,
        [SO_INV_UNIT]   VarChar(50)                        NULL,
        [SO_OKEI]       VarChar(20)                        NULL,
        [SO_ACTIVE]     Bit                            NOT NULL,
        [SO_CODE]       VarChar(100)                       NULL,
        CONSTRAINT [PK_dbo.SaleObjectTable] PRIMARY KEY CLUSTERED ([SO_ID]),
        CONSTRAINT [FK_dbo.SaleObjectTable(SO_ID_TAX)_dbo.TaxTable(TX_ID)] FOREIGN KEY  ([SO_ID_TAX]) REFERENCES [dbo].[TaxTable] ([TX_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.SaleObjectTable(SO_NAME)] ON [dbo].[SaleObjectTable] ([SO_NAME] ASC);
GO
