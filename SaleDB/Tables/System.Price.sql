USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[Price]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_MONTH]    UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]   UniqueIdentifier      NOT NULL,
        [PRICE]       Money                 NOT NULL,
        [LAST]        DateTime              NOT NULL,
        CONSTRAINT [PK_System.Price] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_System.Price(ID_MONTH)_System.Month(ID)] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Month] ([ID]),
        CONSTRAINT [FK_System.Price(ID_SYSTEM)_System.Systems(ID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [System].[Systems] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_System.Price(ID_MONTH)] ON [System].[Price] ([ID_MONTH] ASC);
CREATE NONCLUSTERED INDEX [IX_System.Price(ID_SYSTEM,ID_MONTH)+(PRICE,LAST)] ON [System].[Price] ([ID_SYSTEM] ASC, [ID_MONTH] ASC) INCLUDE ([PRICE], [LAST]);
GO
