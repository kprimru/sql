USE [DBF]
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
        CONSTRAINT [PK_Raw.Incomes:Details] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_Raw.Incomes:Details(Income_Id)_Raw.Incomes(Id)] FOREIGN KEY  ([Income_Id]) REFERENCES [Raw].[Incomes] ([Id])
);
GO
CREATE NONCLUSTERED INDEX [IX_Raw.Incomes:Details(Income_Id)+(Date,INN,Name,Purpose,Num,Price,Client_Id,NotForImport)] ON [Raw].[Incomes:Details] ([Income_Id] ASC) INCLUDE ([Date], [INN], [Name], [Purpose], [Num], [Price], [Client_Id], [NotForImport]);
GO
