USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[PersonalDetail]
(
        [PER_ID]          UniqueIdentifier      NOT NULL,
        [PER_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [PER_ID_DEP]      UniqueIdentifier      NOT NULL,
        [PER_NAME]        VarChar(150)          NOT NULL,
        [PER_ID_TYPE]     UniqueIdentifier      NOT NULL,
        [PER_DATE]        SmallDateTime         NOT NULL,
        [PER_END]         SmallDateTime             NULL,
        [PER_REF]         TinyInt               NOT NULL,
        [PER_EMAIL]       VarChar(256)              NULL,
        CONSTRAINT [PK_Personal.PersonalDetail] PRIMARY KEY CLUSTERED ([PER_ID]),
        CONSTRAINT [FK_Personal.PersonalDetail(PER_ID_DEP)_Personal.Department(DPMS_ID)] FOREIGN KEY  ([PER_ID_DEP]) REFERENCES [Personal].[Department] ([DPMS_ID]),
        CONSTRAINT [FK_Personal.PersonalDetail(PER_ID_TYPE)_Personal.PersonalType(PTMS_ID)] FOREIGN KEY  ([PER_ID_TYPE]) REFERENCES [Personal].[PersonalType] ([PTMS_ID]),
        CONSTRAINT [FK_Personal.PersonalDetail(PER_ID_MASTER)_Personal.Personals(PERMS_ID)] FOREIGN KEY  ([PER_ID_MASTER]) REFERENCES [Personal].[Personals] ([PERMS_ID])
);GO
