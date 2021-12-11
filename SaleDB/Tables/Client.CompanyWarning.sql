USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyWarning]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [DATE]          SmallDateTime         NOT NULL,
        [NOTIFY_USER]   NVarChar(256)         NOT NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [END_DATE]      SmallDateTime             NULL,
        [CREATE_USER]   NVarChar(256)         NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Client.CompanyWarning] PRIMARY KEY CLUSTERED ([ID])
);GO
