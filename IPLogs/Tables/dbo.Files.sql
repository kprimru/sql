USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Files]
(
        [FL_ID]          Int              Identity(1,1)   NOT NULL,
        [FL_ID_SERVER]   Int                                  NULL,
        [FL_NAME]        NVarChar(1024)                   NOT NULL,
        [FL_SIZE]        bigint                           NOT NULL,
        [FL_DATE]        DateTime                         NOT NULL,
        [FL_TYPE]        TinyInt                              NULL,
        [FL_ORIGIN]      NVarChar(1024)                       NULL,
        [FL_MD5]         NVarChar(64)                         NULL,
        CONSTRAINT [PK_dbo.Files] PRIMARY KEY CLUSTERED ([FL_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.Files(FL_DATE,FL_TYPE)+(FL_ID,FL_NAME,FL_SIZE)] ON [dbo].[Files] ([FL_DATE] ASC, [FL_TYPE] ASC) INCLUDE ([FL_ID], [FL_NAME], [FL_SIZE]);
CREATE NONCLUSTERED INDEX [IX_dbo.Files(FL_NAME,FL_ID_SERVER)+(FL_ID,FL_SIZE,FL_TYPE)] ON [dbo].[Files] ([FL_NAME] ASC, [FL_ID_SERVER] ASC) INCLUDE ([FL_ID], [FL_SIZE], [FL_TYPE]);
CREATE NONCLUSTERED INDEX [IX_dbo.Files(FL_TYPE)+(FL_ID,FL_DATE)] ON [dbo].[Files] ([FL_TYPE] ASC) INCLUDE ([FL_ID], [FL_DATE]);
GO
