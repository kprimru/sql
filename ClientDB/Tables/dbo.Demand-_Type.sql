USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Demand->Type]
(
        [Id]          SmallInt       Identity(1,1)   NOT NULL,
        [Name]        VarChar(200)                   NOT NULL,
        [Code]        VarChar(200)                   NOT NULL,
        [SortIndex]   SmallInt                           NULL,
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Demand->__737584F62701A966] ON [dbo].[Demand->Type] ([Name] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ__Demand->__A25C5AA7E642CE4F] ON [dbo].[Demand->Type] ([Code] ASC);
GO
