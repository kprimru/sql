USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientHST]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [PATH]           NVarChar(1024)        NOT NULL,
        [FILE_DATE]      DateTime              NOT NULL,
        [FILE_MD5]       NVarChar(256)         NOT NULL,
        [FILE_SIZE]      bigint                NOT NULL,
        [PROCESS_DATE]   DateTime              NOT NULL,
        CONSTRAINT [PK_dbo.ClientHST] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientHST(FILE_DATE,FILE_MD5,FILE_SIZE)] ON [dbo].[ClientHST] ([FILE_DATE] ASC, [FILE_MD5] ASC, [FILE_SIZE] ASC);
GO
