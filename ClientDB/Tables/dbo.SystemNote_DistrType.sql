USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemNote:DistrType]
(
        [System_Id]      SmallInt       NOT NULL,
        [DistrType_Id]   SmallInt       NOT NULL,
        [Note]           varbinary          NULL,
        [NoteWTitle]     varbinary          NULL,
        CONSTRAINT [PK__SystemNote:Distr__20651BCD] PRIMARY KEY CLUSTERED ([System_Id],[DistrType_Id])
);GO
