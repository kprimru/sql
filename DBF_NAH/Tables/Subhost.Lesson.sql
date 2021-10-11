USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[Lesson]
(
        [LS_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [LS_NAME]     VarChar(50)                   NOT NULL,
        [LS_ORDER]    SmallInt                      NOT NULL,
        [LS_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_Subhost.Lesson] PRIMARY KEY CLUSTERED ([LS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.Lesson(LS_NAME)] ON [Subhost].[Lesson] ([LS_NAME] ASC);
GO
