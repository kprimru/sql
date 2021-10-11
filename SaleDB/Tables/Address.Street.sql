USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Address].[Street]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(512)         NOT NULL,
        [PREFIX]    NVarChar(64)          NOT NULL,
        [SUFFIX]    NVarChar(64)          NOT NULL,
        [ID_CITY]   UniqueIdentifier          NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Street] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Street_City] FOREIGN KEY  ([ID_CITY]) REFERENCES [Address].[City] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_LAST] ON [Address].[Street] ([LAST] ASC);
GO
