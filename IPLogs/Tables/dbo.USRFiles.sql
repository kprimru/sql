USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USRFiles]
(
        [UF_ID]         Int             Identity(1,1)   NOT NULL,
        [UF_ID_FILE]    Int                             NOT NULL,
        [UF_USR_NAME]   NVarChar(256)                       NULL,
        [UF_USR_DATA]   varbinary                           NULL,
        [UF_DATE]       DateTime                            NULL,
        [UF_SYS]        SmallInt                            NULL,
        [UF_DISTR]      Int                                 NULL,
        [UF_COMP]       TinyInt                             NULL,
        [UF_MD5]        NVarChar(64)                        NULL,
        CONSTRAINT [PK_dbo.USRFiles] PRIMARY KEY CLUSTERED ([UF_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.USRFiles(UF_DATE)+(UF_ID)] ON [dbo].[USRFiles] ([UF_DATE] ASC) INCLUDE ([UF_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.USRFiles(UF_DISTR,UF_SYS,UF_COMP)+(UF_DATE)] ON [dbo].[USRFiles] ([UF_DISTR] ASC, [UF_SYS] ASC, [UF_COMP] ASC) INCLUDE ([UF_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.USRFiles(UF_ID_FILE)+(UF_ID,UF_USR_NAME,UF_USR_DATA)] ON [dbo].[USRFiles] ([UF_ID_FILE] ASC) INCLUDE ([UF_ID], [UF_USR_NAME], [UF_USR_DATA]);
CREATE NONCLUSTERED INDEX [IX_dbo.USRFiles(UF_MD5,UF_USR_NAME)] ON [dbo].[USRFiles] ([UF_MD5] ASC, [UF_USR_NAME] ASC);
GO
