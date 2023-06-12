USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientFinancingAddressTable]
(
        [CFA_ID]          Int        Identity(1,1)   NOT NULL,
        [CFA_ID_CLIENT]   Int                        NOT NULL,
        [CFA_ID_FAT]      SmallInt                   NOT NULL,
        [CFA_ID_ATL]      SmallInt                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientFinancingAddressTable] PRIMARY KEY NONCLUSTERED ([CFA_ID]),
        CONSTRAINT [FK_dbo.ClientFinancingAddressTable(CFA_ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([CFA_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.ClientFinancingAddressTable(CFA_ID_FAT)_dbo.FinancingAddressTypeTable(FAT_ID)] FOREIGN KEY  ([CFA_ID_FAT]) REFERENCES [dbo].[FinancingAddressTypeTable] ([FAT_ID]),
        CONSTRAINT [FK_dbo.ClientFinancingAddressTable(CFA_ID_ATL)_dbo.AddressTemplateTable(ATL_ID)] FOREIGN KEY  ([CFA_ID_ATL]) REFERENCES [dbo].[AddressTemplateTable] ([ATL_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientFinancingAddressTable(CFA_ID_CLIENT)] ON [dbo].[ClientFinancingAddressTable] ([CFA_ID_CLIENT] ASC);
GO
