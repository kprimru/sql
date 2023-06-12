USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Contracts->Act Sign Periods]
(
        [Id]     SmallInt       Identity(1,1)   NOT NULL,
        [Code]   VarChar(100)                   NOT NULL,
        [Name]   VarChar(100)                   NOT NULL,
        CONSTRAINT [PK_Contract.Contracts->Act Sign Periods] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Contract.Contracts->Act Sign Periods(Code)] ON [Contract].[Contracts->Act Sign Periods] ([Code] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Contract.Contracts->Act Sign Periods(Name)] ON [Contract].[Contracts->Act Sign Periods] ([Name] ASC);
GO
