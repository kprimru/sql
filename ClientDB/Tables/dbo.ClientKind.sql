USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientKind]
(
        [Id]          SmallInt       Identity(1,1)   NOT NULL,
        [Name]        VarChar(100)                   NOT NULL,
        [SortIndex]   SmallInt                       NOT NULL,
        CONSTRAINT [PK_dbo.ClientKind] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ClientKind()] ON [dbo].[ClientKind] ([Name] ASC);
GO
