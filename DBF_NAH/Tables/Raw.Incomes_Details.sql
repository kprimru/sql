USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Raw].[Incomes:Details]
(
        [Id]             bigint          Identity(1,1)   NOT NULL,
        [Income_Id]      Int                             NOT NULL,
        [Date]           SmallDateTime                   NOT NULL,
        [INN]            VarChar(20)                         NULL,
        [Name]           VarChar(256)                        NULL,
        [Purpose]        VarChar(Max)                        NULL,
        [Num]            VarChar(20)                         NULL,
        [Price]          Money                           NOT NULL,
        [Client_Id]      Int                                 NULL,
        [NotForImport]   Bit                             NOT NULL,
        CONSTRAINT [PK_Raw.Incomes:Details] PRIMARY KEY CLUSTERED ([Id])
);GO
