USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[PersonalType]
(
        [ID]        UniqueIdentifier      NOT NULL,
        [NAME]      NVarChar(256)         NOT NULL,
        [SHORT]     NVarChar(128)         NOT NULL,
        [PSEDO]     NVarChar(128)         NOT NULL,
        [MEETING]   Bit                   NOT NULL,
        [ASSIGN]    Bit                   NOT NULL,
        [LAST]      DateTime              NOT NULL,
        CONSTRAINT [PK_Personal.PersonalType] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Personal.PersonalType(LAST)] ON [Personal].[PersonalType] ([LAST] ASC);
GO
