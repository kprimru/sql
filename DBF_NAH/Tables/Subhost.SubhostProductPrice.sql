USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostProductPrice]
(
        [SPP_ID]           Int        Identity(1,1)   NOT NULL,
        [SPP_ID_PERIOD]    SmallInt                   NOT NULL,
        [SPP_ID_PRODUCT]   SmallInt                   NOT NULL,
        [SPP_PRICE]        Money                      NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostProductPrice] PRIMARY KEY CLUSTERED ([SPP_ID]),
        CONSTRAINT [FK_Subhost.SubhostProductPrice(SPP_ID_PRODUCT)_Subhost.SubhostProduct(SP_ID)] FOREIGN KEY  ([SPP_ID_PRODUCT]) REFERENCES [Subhost].[SubhostProduct] ([SP_ID]),
        CONSTRAINT [FK_Subhost.SubhostProductPrice(SPP_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SPP_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostProductPrice(SPP_ID_PERIOD,SPP_ID_PRODUCT)] ON [Subhost].[SubhostProductPrice] ([SPP_ID_PERIOD] ASC, [SPP_ID_PRODUCT] ASC);
GO
