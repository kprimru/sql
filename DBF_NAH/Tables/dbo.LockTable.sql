USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LockTable]
(
        [LC_ID]             bigint         Identity(1,1)   NOT NULL,
        [LC_DOC_ID]         VarChar(20)                    NOT NULL,
        [LC_SP_ID]          Int                            NOT NULL,
        [LC_HOST_NAME]      VarChar(128)                   NOT NULL,
        [LC_HOST_PROCESS]   VarChar(128)                   NOT NULL,
        [LC_LOGIN_NAME]     VarChar(256)                   NOT NULL,
        [LC_LOGIN_TIME]     DateTime                       NOT NULL,
        [LC_LOCK_TIME]      DateTime                       NOT NULL,
        [LC_TABLE]          VarChar(128)                   NOT NULL,
        [LC_NT_USER]        VarChar(128)                   NOT NULL,
        CONSTRAINT [PK_dbo.LockTable] PRIMARY KEY CLUSTERED ([LC_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.LockTable(LC_DOC_ID,LC_TABLE)] ON [dbo].[LockTable] ([LC_DOC_ID] ASC, [LC_TABLE] ASC);
GO
