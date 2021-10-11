USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[Depo->Statuses]
(
        [Id]          SmallInt       Identity(1,1)   NOT NULL,
        [Code]        VarChar(100)                   NOT NULL,
        [Name]        VarChar(100)                   NOT NULL,
        [Last]        DateTime                       NOT NULL,
        [IsVisible]   Bit                            NOT NULL,
        CONSTRAINT [PK__Depo->Statuses__3ACC9741] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [asdasd] ON [Client].[Depo->Statuses] ([Code] ASC);
GO
