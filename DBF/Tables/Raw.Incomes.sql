USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Raw].[Incomes]
(
        [Id]                Int            Identity(1,1)   NOT NULL,
        [FileName]          VarChar(256)                   NOT NULL,
        [FileDateTime]      DateTime                       NOT NULL,
        [FileSize]          bigint                         NOT NULL,
        [DateTime]          DateTime                       NOT NULL,
        [Organization_Id]   SmallInt                           NULL,
        CONSTRAINT [PK_Raw.Incomes] PRIMARY KEY CLUSTERED ([Id])
);
GO
