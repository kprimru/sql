USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceTypeTable]
(
        [INT_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [INT_NAME]     VarChar(50)                   NOT NULL,
        [INT_PSEDO]    VarChar(50)                   NOT NULL,
        [INT_SALE]     Bit                           NOT NULL,
        [INT_BUY]      Bit                           NOT NULL,
        [INT_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.InvoiceTypeTable] PRIMARY KEY CLUSTERED ([INT_ID])
);GO
