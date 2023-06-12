USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HotlineChat]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [SYS]            SmallInt              NOT NULL,
        [DISTR]          Int                   NOT NULL,
        [COMP]           TinyInt               NOT NULL,
        [FIRST_DATE]     DateTime                  NULL,
        [START]          DateTime                  NULL,
        [FINISH]         DateTime                  NULL,
        [PROFILE]        NVarChar(256)         NOT NULL,
        [FIO]            NVarChar(512)         NOT NULL,
        [EMAIL]          NVarChar(256)         NOT NULL,
        [PHONE]          NVarChar(256)         NOT NULL,
        [CHAT]           NVarChar(Max)         NOT NULL,
        [LGN]            NVarChar(256)         NOT NULL,
        [RIC_PERSONAL]   NVarChar(512)         NOT NULL,
        [LINKS]          NVarChar(Max)         NOT NULL,
        [ID_CLIENT]      Int                       NULL,
        [LOAD_DATE]      DateTime              NOT NULL,
        [IMPORT_DATE]    DateTime                  NULL,
        CONSTRAINT [PK_dbo.HotlineChat] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.HotlineChat(DISTR,SYS,COMP)+INCL] ON [dbo].[HotlineChat] ([DISTR] ASC, [SYS] ASC, [COMP] ASC) INCLUDE ([ID], [FIRST_DATE], [START], [FINISH], [PROFILE], [FIO], [EMAIL], [PHONE], [CHAT], [LGN], [RIC_PERSONAL], [LINKS]);
GO
