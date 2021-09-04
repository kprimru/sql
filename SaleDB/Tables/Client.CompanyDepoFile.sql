USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyDepoFile]
(
        [Id]         Int            Identity(1,1)   NOT NULL,
        [Depo]       xml                                NULL,
        [DateTime]   DateTime                           NULL,
        [UserName]   VarChar(128)                       NULL,
        [HostName]   VarChar(128)                       NULL,
        CONSTRAINT [PK__CompanyDepoFile__66AB197F] PRIMARY KEY CLUSTERED ([Id])
);GO
