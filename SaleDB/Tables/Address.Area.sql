USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Address].[Area]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [ID_CITY]   UniqueIdentifier      NOT NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Area] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Area_City] FOREIGN KEY  ([ID_CITY]) REFERENCES [Address].[City] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [Address].[Area] ([LAST] ASC);
GO
