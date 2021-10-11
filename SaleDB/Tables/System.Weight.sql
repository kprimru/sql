USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [System].[Weight]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MONTH]     UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]    UniqueIdentifier      NOT NULL,
        [VALUE]        decimal               NOT NULL,
        [PROB_VALUE]   decimal               NOT NULL,
        CONSTRAINT [PK_Weight] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Weight_Month] FOREIGN KEY  ([ID_MONTH]) REFERENCES [Common].[Month] ([ID]),
        CONSTRAINT [FK_Weight_Systems] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [System].[Systems] ([ID])
);GO
