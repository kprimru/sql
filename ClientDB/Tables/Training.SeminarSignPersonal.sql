USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Training].[SeminarSignPersonal]
(
        [SSP_ID]            UniqueIdentifier      NOT NULL,
        [SSP_ID_SIGN]       UniqueIdentifier      NOT NULL,
        [SSP_SURNAME]       VarChar(150)              NULL,
        [SSP_NAME]          VarChar(150)              NULL,
        [SSP_PATRON]        VarChar(150)              NULL,
        [SSP_POS]           VarChar(150)              NULL,
        [SSP_PHONE]         VarChar(150)              NULL,
        [SSP_CANCEL]        TinyInt               NOT NULL,
        [SSP_NOTE]          VarChar(Max)              NULL,
        [SSP_STUDY]         Bit                       NULL,
        [SSP_CREATE_USER]   NVarChar(256)             NULL,
        [SSP_CREATE_DATE]   DateTime                  NULL,
        CONSTRAINT [PK_Training.SeminarSignPersonal] PRIMARY KEY NONCLUSTERED ([SSP_ID]),
        CONSTRAINT [FK_Training.SeminarSignPersonal(SSP_ID_SIGN)_Training.SeminarSign(SP_ID)] FOREIGN KEY  ([SSP_ID_SIGN]) REFERENCES [Training].[SeminarSign] ([SP_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Training.SeminarSignPersonal(SSP_ID_SIGN,SSP_ID)] ON [Training].[SeminarSignPersonal] ([SSP_ID_SIGN] ASC, [SSP_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarSignPersonal(SSP_NAME)] ON [Training].[SeminarSignPersonal] ([SSP_NAME] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarSignPersonal(SSP_PATRON)] ON [Training].[SeminarSignPersonal] ([SSP_PATRON] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarSignPersonal(SSP_POS)] ON [Training].[SeminarSignPersonal] ([SSP_POS] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarSignPersonal(SSP_SURNAME)] ON [Training].[SeminarSignPersonal] ([SSP_SURNAME] ASC);
GO
