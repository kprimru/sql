USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Meta].[Fields]
(
        [FL_ID]        UniqueIdentifier      NOT NULL,
        [FL_NAME]      VarChar(50)           NOT NULL,
        [FL_CAPTION]   VarChar(50)           NOT NULL,
        [FL_WIDTH]     SmallInt              NOT NULL,
        [FL_VISIBLE]   Bit                   NOT NULL,
        [FL_SYSTEM]    Bit                   NOT NULL,
        CONSTRAINT [PK_Fields] PRIMARY KEY CLUSTERED ([FL_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Fields] ON [Meta].[Fields] ([FL_NAME] ASC);
GO
