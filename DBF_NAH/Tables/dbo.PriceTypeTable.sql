USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceTypeTable]
(
        [PT_ID]         SmallInt      Identity(1,1)   NOT NULL,
        [PT_NAME]       VarChar(50)                   NOT NULL,
        [PT_ID_GROUP]   SmallInt                          NULL,
        [PT_COEF]       Bit                               NULL,
        [PT_ACTIVE]     Bit                               NULL,
        [PT_ORDER]      Int                               NULL,
        CONSTRAINT [PK_dbo.PriceTypeTable] PRIMARY KEY CLUSTERED ([PT_ID]),
        CONSTRAINT [FK_dbo.PriceTypeTable(PT_ID_GROUP)_dbo.PriceGroupTable(PG_ID)] FOREIGN KEY  ([PT_ID_GROUP]) REFERENCES [dbo].[PriceGroupTable] ([PG_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.PriceTypeTable()] ON [dbo].[PriceTypeTable] ([PT_NAME] ASC);
GO
