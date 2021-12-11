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
        CONSTRAINT [PK_Client.CallDate] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Client.CallDate(ID_COMPANY)] ON [Client].[CallDate] ([ID_COMPANY] ASC);
GO
