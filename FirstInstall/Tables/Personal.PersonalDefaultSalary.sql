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
        CONSTRAINT [PK_PersonalSalary_1] PRIMARY KEY CLUSTERED ([PDS_ID]),
        CONSTRAINT [FK_PersonalSalary_Personals] FOREIGN KEY  ([PDS_ID_PERSONAL]) REFERENCES [Personal].[Personals] ([PERMS_ID]),
        CONSTRAINT [FK_PersonalSalary_Period] FOREIGN KEY  ([PDS_ID_PERIOD]) REFERENCES [Common].[Period] ([PRMS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PersonalDefaultSalary] ON [Personal].[PersonalDefaultSalary] ([PDS_ID_PERIOD] ASC, [PDS_ID_PERSONAL] ASC);
GO
