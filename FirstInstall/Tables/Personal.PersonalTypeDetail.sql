USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[PersonalTypeDetail]
(
        [PT_ID]          UniqueIdentifier      NOT NULL,
        [PT_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [PT_NAME]        VarChar(50)           NOT NULL,
        [PT_ALIAS]       VarChar(50)           NOT NULL,
        [PT_DATE]        SmallDateTime         NOT NULL,
        [PT_END]         SmallDateTime             NULL,
        [PT_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_PersonalType] PRIMARY KEY CLUSTERED ([PT_ID]),
        CONSTRAINT [FK_PersonalType_PersonalType] FOREIGN KEY  ([PT_ID_MASTER]) REFERENCES [Personal].[PersonalType] ([PTMS_ID])
);GO
