USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyActivity]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_COMPANY]    UniqueIdentifier      NOT NULL,
        [ID_ACTIVITY]   UniqueIdentifier      NOT NULL,
        CONSTRAINT [PK_Client.CompanyActivity] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Client.CompanyActivity(ID_ACTIVITY)] ON [Client].[CompanyActivity] ([ID_ACTIVITY] ASC, [ID_COMPANY] ASC);
CREATE NONCLUSTERED INDEX [IX_Client.CompanyActivity(ID_COMPANY)] ON [Client].[CompanyActivity] ([ID_COMPANY] ASC, [ID_ACTIVITY] ASC);
GO
