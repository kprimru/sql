USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostEmail_Type]
(
        [Id]     TinyInt        Identity(1,1)   NOT NULL,
        [Code]   VarChar(100)                   NOT NULL,
        [Name]   VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_dbo.SubhostEmail_Type] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SubhostEmail_Type(Code)] ON [dbo].[SubhostEmail_Type] ([Code] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SubhostEmail_Type(Name)] ON [dbo].[SubhostEmail_Type] ([Name] ASC);
GO
