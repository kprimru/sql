USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[Stage]
(
        [ST_ID]           SmallInt   Identity(1,1)   NOT NULL,
        [ST_ID_QUARTER]   SmallInt                   NOT NULL,
        [ST_VALUE]        decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.Stage] PRIMARY KEY CLUSTERED ([ST_ID])
);GO
