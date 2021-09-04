USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[LessonPosition]
(
        [LP_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [LP_NAME]     VarChar(50)                   NOT NULL,
        [LP_ORDER]    SmallInt                      NOT NULL,
        [LP_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_Subhost.LessonPosition] PRIMARY KEY CLUSTERED ([LP_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.LessonPosition(LP_NAME)] ON [Subhost].[LessonPosition] ([LP_NAME] ASC);
GO
