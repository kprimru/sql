USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSearchFiles]
(
        [CSF_ID]          Int            Identity(1,1)   NOT NULL,
        [CSF_ID_CLIENT]   Int                            NOT NULL,
        [CSF_MD5]         VarChar(100)                   NOT NULL,
        [CSF_FILE]        varbinary                      NOT NULL,
        [CSF_DATE]        DateTime                       NOT NULL,
        CONSTRAINT [PK_dbo.ClientSearchFiles] PRIMARY KEY CLUSTERED ([CSF_ID]),
        CONSTRAINT [FK_dbo.ClientSearchFiles(CSF_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CSF_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientSearchFiles(CSF_MD5)] ON [dbo].[ClientSearchFiles] ([CSF_MD5] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientSearchFiles(CSF_MD5)+(CSF_ID_CLIENT,CSF_FILE,CSF_DATE)] ON [dbo].[ClientSearchFiles] ([CSF_MD5] ASC) INCLUDE ([CSF_ID_CLIENT], [CSF_FILE], [CSF_DATE]);
GO
