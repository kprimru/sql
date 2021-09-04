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
        CONSTRAINT [PK_Personals] PRIMARY KEY CLUSTERED ([PER_ID]),
        CONSTRAINT [FK_Personals_Department] FOREIGN KEY  ([PER_ID_DEP]) REFERENCES [Personal].[Department] ([DPMS_ID]),
        CONSTRAINT [FK_Personals_PersonalType] FOREIGN KEY  ([PER_ID_TYPE]) REFERENCES [Personal].[PersonalType] ([PTMS_ID]),
        CONSTRAINT [FK_Personals_Personals] FOREIGN KEY  ([PER_ID_MASTER]) REFERENCES [Personal].[Personals] ([PERMS_ID])
);GO
