USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyFiles]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [FILE_NAME]    NVarChar(1024)        NOT NULL,
        [FILE_DATA]    varbinary                 NULL,
        [FILE_NOTE]    NVarChar(1024)        NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        [BDATE]        DateTime              NOT NULL,
        [EDATE]        DateTime                  NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_CompanyFiles] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CompanyFiles_Company] FOREIGN KEY  ([ID_COMPANY]) REFERENCES [Client].[Company] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_COMPANY] ON [Client].[CompanyFiles] ([ID_COMPANY] ASC, [STATUS] ASC) INCLUDE ([ID], [FILE_NAME], [FILE_NOTE]);
GO
