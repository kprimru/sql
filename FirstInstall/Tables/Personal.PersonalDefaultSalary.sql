USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[PersonalDefaultSalary]
(
        [PDS_ID]            UniqueIdentifier      NOT NULL,
        [PDS_ID_PERSONAL]   UniqueIdentifier      NOT NULL,
        [PDS_ID_PERIOD]     UniqueIdentifier      NOT NULL,
        [PDS_VALUE]         Money                 NOT NULL,
        [PDS_COMMENT]       VarChar(500)          NOT NULL,
        CONSTRAINT [PK_Personal.PersonalDefaultSalary] PRIMARY KEY CLUSTERED ([PDS_ID]),
        CONSTRAINT [FK_Personal.PersonalDefaultSalary(PDS_ID_PERSONAL)_Personal.Personals(PERMS_ID)] FOREIGN KEY  ([PDS_ID_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID]),
        CONSTRAINT [FK_Personal.PersonalDefaultSalary(PDS_ID_PERIOD)_Personal.Period(PRMS_ID)] FOREIGN KEY  ([PDS_ID_PERIOD]) REFERENCES [Common].[Period] ([PRMS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Personal.PersonalDefaultSalary(PDS_ID_PERIOD,PDS_ID_PERSONAL)] ON [Personal].[PersonalDefaultSalary] ([PDS_ID_PERIOD] ASC, [PDS_ID_PERSONAL] ASC);
GO
