USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[USRFile]
(
        [UF_ID]            Int             Identity(1,1)   NOT NULL,
        [UF_ID_COMPLECT]   Int                             NOT NULL,
        [UF_PATH]          TinyInt                         NOT NULL,
        [UF_MD5]           VarChar(100)                    NOT NULL,
        [UF_NAME]          VarChar(50)                     NOT NULL,
        [UF_DATE]          DateTime                            NULL,
        [UF_ID_KIND]       TinyInt                         NOT NULL,
        [UF_UPTIME]        VarChar(20)                         NULL,
        [UF_ACTIVE]        Bit                             NOT NULL,
        [UF_CREATE]        DateTime                        NOT NULL,
        [UF_USER]          NVarChar(256)                   NOT NULL,
        [UF_MIN_DATE]      SmallDateTime                       NULL,
        [UF_MAX_DATE]      SmallDateTime                       NULL,
        [UF_COMPLIANCE]    VarChar(20)                         NULL,
        [UF_ID_MANAGER]    Int                                 NULL,
        [UF_ID_SERVICE]    Int                                 NULL,
        [UF_ID_CLIENT]     Int                                 NULL,
        [UF_SESSION]       VarChar(50)                         NULL,
        [UF_ID_SYSTEM]     Int                                 NULL,
        [UF_DISTR]         Int                                 NULL,
        [UF_COMP]          TinyInt                             NULL,
        [UF_HASH]          VarChar(100)                        NULL,
        CONSTRAINT [PK_USR.USRFile] PRIMARY KEY NONCLUSTERED ([UF_ID]),
        CONSTRAINT [FK_USR.USRFile(UF_ID_CLIENT)_USR.ClientTable(ClientID)] FOREIGN KEY  ([UF_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_USR.USRFile(UF_ID_SYSTEM)_USR.SystemTable(SystemID)] FOREIGN KEY  ([UF_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_USR.USRFile(UF_ID_KIND)_USR.USRFileKindTable(USRFileKindID)] FOREIGN KEY  ([UF_ID_KIND]) REFERENCES [dbo].[USRFileKindTable] ([USRFileKindID])
);
GO
CREATE CLUSTERED INDEX [IC_USR.USRFile(UF_ID_COMPLECT,UF_DATE)] ON [USR].[USRFile] ([UF_ID_COMPLECT] ASC, [UF_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRFile(UF_HASH,UF_NAME,UF_ID)] ON [USR].[USRFile] ([UF_HASH] ASC, [UF_NAME] ASC, [UF_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_USR.USRFile(UF_ID_COMPLECT,UF_PATH,UF_MAX_DATE)+INCL] ON [USR].[USRFile] ([UF_ID_COMPLECT] ASC, [UF_PATH] ASC, [UF_MAX_DATE] ASC) INCLUDE ([UF_ID], [UF_CREATE], [UF_ID_KIND], [UF_UPTIME], [UF_ACTIVE], [UF_NAME]);
CREATE NONCLUSTERED INDEX [IX_USR.USRFile(UF_MD5,UF_NAME,UF_ID_COMPLECT)+(UF_ID,UF_DATE)] ON [USR].[USRFile] ([UF_MD5] ASC, [UF_NAME] ASC, [UF_ID_COMPLECT] ASC) INCLUDE ([UF_ID], [UF_DATE]);
GO
GRANT SELECT ON [USR].[USRFile] TO claim_view;
GO
