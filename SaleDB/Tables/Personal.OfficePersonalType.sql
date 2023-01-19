USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[OfficePersonalType]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [ID_TYPE]       UniqueIdentifier      NOT NULL,
        [BDATE]         DateTime              NOT NULL,
        [EDATE]         DateTime                  NULL,
        CONSTRAINT [PK_Personal.OfficePersonalType] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Personal.OfficePersonalType(ID_TYPE)_Personal.PersonalType(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [Personal].[PersonalType] ([ID]),
        CONSTRAINT [FK_Personal.OfficePersonalType(ID_PERSONAL)_Personal.OfficePersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [Personal].[OfficePersonal] ([ID])
);
GO
