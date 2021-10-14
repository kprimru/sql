USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Schedules->Statuses]
(
        [Id]          char(1)        Collate Cyrillic_General_BIN   NOT NULL,
        [Code]        VarChar(100)   Collate Cyrillic_General_BIN   NOT NULL,
        [Name]        VarChar(100)                                  NOT NULL,
        [Color]       Int                                           NOT NULL,
        [SortIndex]   TinyInt                                       NOT NULL,
        CONSTRAINT [PK_Seminar.Schedules->Statuses] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Seminar.Schedules->Statuses(Code)] ON [Seminar].[Schedules->Statuses] ([Code] ASC);
GO
