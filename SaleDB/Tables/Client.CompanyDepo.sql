USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CompanyDepo]
(
        [Id]                  UniqueIdentifier      NOT NULL,
        [Master_Id]           UniqueIdentifier          NULL,
        [Company_Id]          UniqueIdentifier      NOT NULL,
        [DateFrom]            SmallDateTime             NULL,
        [DateTo]              SmallDateTime             NULL,
        [Number]              Int                       NULL,
        [ExpireDate]          SmallDateTime             NULL,
        [Status_Id]           SmallInt              NOT NULL,
        [Depo:Name]           VarChar(256)          NOT NULL,
        [Depo:Inn]            VarChar(20)           NOT NULL,
        [Depo:Region]         VarChar(10)           NOT NULL,
        [Depo:City]           VarChar(128)          NOT NULL,
        [Depo:Address]        VarChar(256)          NOT NULL,
        [Depo:Person1FIO]     VarChar(256)          NOT NULL,
        [Depo:Person1Phone]   VarChar(256)          NOT NULL,
        [Depo:Person2FIO]     VarChar(256)              NULL,
        [Depo:Person2Phone]   VarChar(256)              NULL,
        [Depo:Person3FIO]     VarChar(256)              NULL,
        [Depo:Person3Phone]   VarChar(256)              NULL,
        [Depo:Rival]          VarChar(10)           NOT NULL,
        [Status]              TinyInt               NOT NULL,
        [UpdDate]             DateTime              NOT NULL,
        [UpdUser]             VarChar(256)          NOT NULL,
        [SortIndex]           Int                       NULL,
        CONSTRAINT [PK_Client.CompanyDepo] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE CLUSTERED INDEX [IX_COMPANY] ON [Client].[CompanyDepo] ([Company_Id] ASC);
CREATE NONCLUSTERED INDEX [IX_COMPANY2] ON [Client].[CompanyDepo] ([Company_Id] ASC, [Status] ASC, [Status_Id] ASC, [DateFrom] ASC) INCLUDE ([Number]);
CREATE NONCLUSTERED INDEX [IX_NUM] ON [Client].[CompanyDepo] ([Number] ASC, [Status] ASC) INCLUDE ([Company_Id], [Status_Id]);
GO
