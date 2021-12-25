USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostSystem]
(
        [SS_ID]            Int              NOT NULL,
        [SS_ID_PERIOD]     SmallInt         NOT NULL,
        [SS_ID_SUBHOST]    SmallInt         NOT NULL,
        [SYS_ID]           SmallInt         NOT NULL,
        [SYS_SHORT_NAME]   VarChar(50)      NOT NULL,
        [SYS_OLD]          VarChar(50)          NULL,
        [SYS_NEW]          VarChar(50)          NULL,
        [SYS_ORDER]        Int                  NULL,
        [SYS_KBU]          decimal              NULL,
        CONSTRAINT [PK_Subhost.SubhostSystem] PRIMARY KEY CLUSTERED ([SS_ID])
);GO
