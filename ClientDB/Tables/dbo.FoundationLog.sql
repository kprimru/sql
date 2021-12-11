USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoundationLog]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_CONTRACT]   Int                   NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.FoundationLog] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.FoundationLog(ID_CONTRACT)_dbo.ContractTable(ContractID)] FOREIGN KEY  ([ID_CONTRACT]) REFERENCES [dbo].[ContractTable] ([ContractID])
);
GO
