USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyIndexQueue]
(
        [Id]           bigint             Identity(1,1)   NOT NULL,
        [ID_COMPANY]   UniqueIdentifier                   NOT NULL,
        CONSTRAINT [PK__CompanyIndexQueu__1EEF72A2] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE NONCLUSTERED INDEX [IX_COMPANY] ON [Client].[CompanyIndexQueue] ([ID_COMPANY] ASC);
GO
