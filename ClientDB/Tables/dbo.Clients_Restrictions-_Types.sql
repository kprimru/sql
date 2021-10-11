USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients:Restrictions->Types]
(
        [Id]     SmallInt       Identity(1,1)   NOT NULL,
        [Code]   VarChar(100)                   NOT NULL,
        [Name]   VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_dbo.Clients:Restrictions->Types] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.Clients:Restrictions->Types(Code)] ON [dbo].[Clients:Restrictions->Types] ([Code] ASC);
GO
