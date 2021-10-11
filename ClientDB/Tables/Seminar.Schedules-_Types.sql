USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Seminar].[Schedules->Types]
(
        [Id]     SmallInt       Identity(1,1)   NOT NULL,
        [Code]   VarChar(100)                   NOT NULL,
        [Name]   VarChar(256)                   NOT NULL,
        CONSTRAINT [PK_Seminar.Schedules->Types] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Seminar.Schedules->Types(Code)] ON [Seminar].[Schedules->Types] ([Code] ASC);
GO
