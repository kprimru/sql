USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegNodeTable]
(
        [ID]              Int             Identity(1,1)   NOT NULL,
        [SystemName]      VarChar(20)                     NOT NULL,
        [DistrNumber]     Int                                 NULL,
        [CompNumber]      TinyInt                             NULL,
        [DistrType]       VarChar(20)                         NULL,
        [TechnolType]     VarChar(20)                         NULL,
        [NetCount]        Int                                 NULL,
        [SubHost]         Int                                 NULL,
        [TransferCount]   Int                                 NULL,
        [TransferLeft]    Int                                 NULL,
        [Service]         Int                                 NULL,
        [RegisterDate]    VarChar(20)                         NULL,
        [Comment]         VarChar(255)                        NULL,
        [Complect]        VarChar(20)                         NULL,
        [Offline]         VarChar(50)                         NULL,
        [YubiKey]         VarChar(50)                         NULL,
        [KrfNeed]         VarChar(50)                         NULL,
        [KrfDop]          VarChar(50)                         NULL,
        [AddParam]        VarChar(50)                         NULL,
        [ODOn]            VarChar(20)                         NULL,
        [ODOff]           VarChar(20)                         NULL,
        [FirstReg]        SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.RegNodeTable] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.RegNodeTable(DistrNumber,SystemName,CompNumber)] ON [dbo].[RegNodeTable] ([DistrNumber] ASC, [SystemName] ASC, [CompNumber] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.RegNodeTable(Complect)] ON [dbo].[RegNodeTable] ([Complect] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.RegNodeTable(Service)+(Complect)] ON [dbo].[RegNodeTable] ([Service] ASC) INCLUDE ([Complect]);
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20230416-012411] ON [dbo].[RegNodeTable] ([Comment] ASC) INCLUDE ([Complect]);
GO
GRANT SELECT ON [dbo].[RegNodeTable] TO BL_READER;
GRANT SELECT ON [dbo].[RegNodeTable] TO claim_view;
GO
