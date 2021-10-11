USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrReplace]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [OLD_HOST]    SmallInt              NOT NULL,
        [OLD_DISTR]   Int                   NOT NULL,
        [OLD_COMP]    TinyInt               NOT NULL,
        [NEW_HOST]    SmallInt              NOT NULL,
        [NEW_DISTR]   Int                   NOT NULL,
        [NEW_COMP]    TinyInt               NOT NULL,
        [DATE]        SmallDateTime             NULL,
        [PERIOD]      SmallInt                  NULL,
        CONSTRAINT [PK_dbo.DistrReplace] PRIMARY KEY CLUSTERED ([ID])
);GO
