USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostDistr]
(
        [SD_ID]            Int            Identity(1,1)   NOT NULL,
        [SD_ID_PERIOD]     SmallInt                       NOT NULL,
        [SD_ID_SUBHOST]    SmallInt                       NOT NULL,
        [SD_TYPE]          VarChar(20)                    NOT NULL,
        [SST_ID]           SmallInt                       NOT NULL,
        [SYS_SHORT_NAME]   VarChar(100)                       NULL,
        [TITLE]            VarChar(50)                        NULL,
        [SYS_COUNT]        SmallInt                           NULL,
        CONSTRAINT [PK_Subhost.SubhostDistr] PRIMARY KEY CLUSTERED ([SD_ID])
);GO
