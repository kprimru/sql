USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [USR].[Groups]
(
        [Id]          TinyInt        Identity(1,1)   NOT NULL,
        [Code]        VarChar(100)                   NOT NULL,
        [Name]        VarChar(100)                   NOT NULL,
        [SortIndex]   TinyInt                        NOT NULL,
        CONSTRAINT [PK_USR.Groups] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_USR.Groups(Code)] ON [USR].[Groups] ([Code] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_USR.Groups(Name)] ON [USR].[Groups] ([Name] ASC);
GO
