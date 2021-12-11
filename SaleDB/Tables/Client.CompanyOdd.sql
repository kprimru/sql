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
        CONSTRAINT [PK_Client.CompanyOdd] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE CLUSTERED INDEX [IC_Client.CompanyOdd(Distr,Host_Id,Comp)] ON [Client].[CompanyOdd] ([Distr] ASC, [Host_Id] ASC, [Comp] ASC);
GO
