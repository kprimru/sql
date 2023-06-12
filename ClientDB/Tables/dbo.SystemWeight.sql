USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemWeight]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        [WEIGHT]      decimal               NOT NULL,
        [WEIGHT2]     decimal                   NULL,
        [ID_PERIOD]   UniqueIdentifier          NULL,
        CONSTRAINT [PK_dbo.SystemWeight] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.SystemWeight(ID_PERIOD)_dbo.Period(ID)] FOREIGN KEY  ([ID_PERIOD]) REFERENCES [Common].[Period] ([ID]),
        CONSTRAINT [FK_dbo.SystemWeight(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.SystemWeight(ID_PERIOD,ID_SYSTEM)+(WEIGHT)] ON [dbo].[SystemWeight] ([ID_PERIOD] ASC, [ID_SYSTEM] ASC) INCLUDE ([WEIGHT]);
CREATE NONCLUSTERED INDEX [IX_dbo.SystemWeight(ID_SYSTEM,ID_PERIOD)+(WEIGHT,WEIGHT2)] ON [dbo].[SystemWeight] ([ID_SYSTEM] ASC, [ID_PERIOD] ASC) INCLUDE ([WEIGHT], [WEIGHT2]);
GO
