USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Training].[SeminarSign]
(
        [SP_ID]           UniqueIdentifier      NOT NULL,
        [SP_ID_SEMINAR]   UniqueIdentifier      NOT NULL,
        [SP_ID_CLIENT]    Int                   NOT NULL,
        CONSTRAINT [PK_Training.SeminarSign] PRIMARY KEY NONCLUSTERED ([SP_ID]),
        CONSTRAINT [FK_Training.SeminarSign(SP_ID_CLIENT)_Training.ClientTable(ClientID)] FOREIGN KEY  ([SP_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_Training.SeminarSign(SP_ID_SEMINAR)_Training.TrainingSchedule(TSC_ID)] FOREIGN KEY  ([SP_ID_SEMINAR]) REFERENCES [Training].[TrainingSchedule] ([TSC_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Training.SeminarSign(SP_ID_SEMINAR,SP_ID)] ON [Training].[SeminarSign] ([SP_ID_SEMINAR] ASC, [SP_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_Training.SeminarSign(SP_ID_CLIENT)] ON [Training].[SeminarSign] ([SP_ID_CLIENT] ASC);
GO
