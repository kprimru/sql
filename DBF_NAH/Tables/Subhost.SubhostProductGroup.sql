USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostProductGroup]
(
        [SPG_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [SPG_NAME]     VarChar(50)                   NOT NULL,
        [SPG_ORDER]    SmallInt                      NOT NULL,
        [SPG_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostProductGroup] PRIMARY KEY CLUSTERED ([SPG_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostProductGroup(SPG_NAME)] ON [Subhost].[SubhostProductGroup] ([SPG_NAME] ASC);
GO
