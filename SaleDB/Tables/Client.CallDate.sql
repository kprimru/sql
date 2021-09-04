USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Client].[CallDate]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_COMPANY]   UniqueIdentifier      NOT NULL,
        [DATE]         SmallDateTime         NOT NULL,
        CONSTRAINT [PK_CallDate] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [IX_CallDate] ON [Client].[CallDate] ([ID_COMPANY] ASC);
GO
