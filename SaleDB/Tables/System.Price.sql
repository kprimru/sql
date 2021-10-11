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
        CONSTRAINT [PK_Price] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Price_Month] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Month] ([ID]),
        CONSTRAINT [FK_Price_Systems] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [System].[Systems] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Price_ID_MONTH] ON [System].[Price] ([ID_MONTH] ASC);
CREATE NONCLUSTERED INDEX [IX_SYSTEM] ON [System].[Price] ([ID_SYSTEM] ASC, [ID_MONTH] ASC) INCLUDE ([PRICE], [LAST]);
GO
