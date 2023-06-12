USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractDocument]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_CONTRACT]   Int                   NOT NULL,
        [ID_TYPE]       UniqueIdentifier      NOT NULL,
        [DATE]          SmallDateTime         NOT NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [FIXED]         Money                     NULL,
        [STATUS]        SmallInt              NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ContractDocument] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ContractDocument(ID_CONTRACT)_dbo.ContractTable(ContractID)] FOREIGN KEY  ([ID_CONTRACT]) REFERENCES [dbo].[ContractTable] ([ContractID]),
        CONSTRAINT [FK_dbo.ContractDocument(ID_TYPE)_dbo.DocumentType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [dbo].[DocumentType] ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ContractDocument(ID_CONTRACT)] ON [dbo].[ContractDocument] ([ID_CONTRACT] ASC);
GO
