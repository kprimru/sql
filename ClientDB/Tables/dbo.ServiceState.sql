USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceState]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [DATE]         DateTime              NOT NULL,
        [ID_SERVICE]   Int                   NOT NULL,
        [STATUS]       TinyInt               NOT NULL,
        CONSTRAINT [PK_dbo.ServiceState] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ServiceState(DATE,STATUS)+(ID)] ON [dbo].[ServiceState] ([DATE] ASC, [STATUS] ASC) INCLUDE ([ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ServiceState(ID_SERVICE,STATUS)+(ID)] ON [dbo].[ServiceState] ([ID_SERVICE] ASC, [STATUS] ASC) INCLUDE ([ID]);
GO
