USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceSystemType]
(
        [PST_ID]          Int             Identity(1,1)   NOT NULL,
        [PST_ID_SYSTEM]   SmallInt                        NOT NULL,
        [PST_ID_PRICE]    SmallInt                        NOT NULL,
        [PST_ID_TYPE]     SmallInt                        NOT NULL,
        [PST_COEF]        decimal                             NULL,
        [PST_FIXED]       Money                               NULL,
        [PST_DISCOUNT]    decimal                             NULL,
        [PST_START]       SmallDateTime                   NOT NULL,
        [PST_END]         SmallDateTime                       NULL,
        [PST_ACTIVE]      Bit                             NOT NULL,
        CONSTRAINT [PK_dbo.PriceSystemType] PRIMARY KEY CLUSTERED ([PST_ID]),
        CONSTRAINT [FK_dbo.PriceSystemType(PST_ID_PRICE)_dbo.PriceTypeTable(PT_ID)] FOREIGN KEY  ([PST_ID_PRICE]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID]),
        CONSTRAINT [FK_dbo.PriceSystemType(PST_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([PST_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_dbo.PriceSystemType(PST_ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([PST_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);
GO
