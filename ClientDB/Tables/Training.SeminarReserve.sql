USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Training].[SeminarReserve]
(
        [SR_ID]            UniqueIdentifier      NOT NULL,
        [SR_ID_SUBJECT]    UniqueIdentifier      NOT NULL,
        [SR_ID_CLIENT]     Int                   NOT NULL,
        [SR_SURNAME]       VarChar(150)              NULL,
        [SR_NAME]          VarChar(150)              NULL,
        [SR_PATRON]        VarChar(150)              NULL,
        [SR_POS]           VarChar(150)              NULL,
        [SR_PHONE]         VarChar(150)              NULL,
        [SR_NOTE]          VarChar(Max)              NULL,
        [SR_CREATE_USER]   NVarChar(256)             NULL,
        [SR_CREATE_DATE]   DateTime                  NULL,
        CONSTRAINT [PK_Training.SeminarReserve] PRIMARY KEY NONCLUSTERED ([SR_ID]),
        CONSTRAINT [FK_Training.SeminarReserve(SR_ID_SUBJECT)_Training.TrainingSubject(TS_ID)] FOREIGN KEY  ([SR_ID_SUBJECT]) REFERENCES [Training].[TrainingSubject] ([TS_ID]),
        CONSTRAINT [FK_Training.SeminarReserve(SR_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([SR_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Training.SeminarReserve(SR_ID_SUBJECT,SR_ID)] ON [Training].[SeminarReserve] ([SR_ID_SUBJECT] ASC, [SR_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarReserve(SR_NAME)] ON [Training].[SeminarReserve] ([SR_NAME] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarReserve(SR_PATRON)] ON [Training].[SeminarReserve] ([SR_PATRON] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarReserve(SR_POS)] ON [Training].[SeminarReserve] ([SR_POS] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarReserve(SR_SURNAME)] ON [Training].[SeminarReserve] ([SR_SURNAME] ASC);
GO
