USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[ClientContractsDocuments]
(
        [Contract_Id]   UniqueIdentifier      NOT NULL,
        [RowIndex]      SmallInt              NOT NULL,
        [Type_Id]       UniqueIdentifier      NOT NULL,
        [Date]          SmallDateTime         NOT NULL,
        [Note]          VarChar(Max)              NULL,
        CONSTRAINT [PK_Contract.ClientContractsDocuments] PRIMARY KEY CLUSTERED ([Contract_Id],[RowIndex])
);GO
