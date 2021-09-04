USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Templates->Types]
(
        [Id]     SmallInt       Identity(1,1)   NOT NULL,
        [Code]   VarChar(100)                   NOT NULL,
        [Name]   VarChar(256)                   NOT NULL,
        CONSTRAINT [PK_Seminar.Templates->Types] PRIMARY KEY CLUSTERED ([Id])
);GO
