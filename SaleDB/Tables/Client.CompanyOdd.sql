USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyOdd]
(
        [Id]           UniqueIdentifier      NOT NULL,
        [Company_Id]   UniqueIdentifier          NULL,
        [Host_Id]      SmallInt              NOT NULL,
        [Distr]        Int                   NOT NULL,
        [Comp]         TinyInt               NOT NULL,
        [UpdDate]      DateTime              NOT NULL,
        [UpdUser]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK__CompanyOdd__7D8E7ED7] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE CLUSTERED INDEX [IX] ON [Client].[CompanyOdd] ([Distr] ASC, [Host_Id] ASC, [Comp] ASC);
GO
