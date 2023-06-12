USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Poll].[Question]
(
        [ID]         UniqueIdentifier      NOT NULL,
        [ID_BLANK]   UniqueIdentifier      NOT NULL,
        [TP]         TinyInt               NOT NULL,
        [ANS_MIN]    SmallInt                  NULL,
        [ANS_MAX]    SmallInt                  NULL,
        [NAME]       NVarChar(1024)        NOT NULL,
        [ORD]        SmallInt              NOT NULL,
        CONSTRAINT [PK_Poll.Question] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Poll.Question(ID_BLANK)_Poll.Blank(ID)] FOREIGN KEY  ([ID_BLANK]) REFERENCES [Poll].[Blank] ([ID])
);
GO
