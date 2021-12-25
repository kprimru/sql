USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinancingAddressTypeTable]
(
        [FAT_ID]             SmallInt       Identity(1,1)   NOT NULL,
        [FAT_ID_ADDR_TYPE]   TinyInt                            NULL,
        [FAT_DOC]            VarChar(50)                    NOT NULL,
        [FAT_NOTE]           VarChar(100)                   NOT NULL,
        [FAT_TEXT]           VarChar(50)                        NULL,
        [FAT_ACTIVE]         Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.FinancingAddressTypeTable] PRIMARY KEY CLUSTERED ([FAT_ID]),
        CONSTRAINT [FK_dbo.FinancingAddressTypeTable(FAT_ID_ADDR_TYPE)_dbo.AddressTypeTable(AT_ID)] FOREIGN KEY  ([FAT_ID_ADDR_TYPE]) REFERENCES [dbo].[AddressTypeTable] ([AT_ID])
);GO
