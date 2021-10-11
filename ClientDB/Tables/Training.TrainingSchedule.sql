USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Training].[TrainingSchedule]
(
        [TSC_ID]          UniqueIdentifier      NOT NULL,
        [TSC_ID_TS]       UniqueIdentifier      NOT NULL,
        [TSC_DATE]        SmallDateTime         NOT NULL,
        [TSC_ID_LECTOR]   UniqueIdentifier          NULL,
        [TSC_LAST]        DateTime              NOT NULL,
        [TSC_LIMIT]       SmallInt                  NULL,
        CONSTRAINT [PK_Training.TrainingSchedule] PRIMARY KEY CLUSTERED ([TSC_ID]),
        CONSTRAINT [FK_Training.TrainingSchedule(TSC_ID_TS)_Training.TrainingSubject(TS_ID)] FOREIGN KEY  ([TSC_ID_TS]) REFERENCES [Training].[TrainingSubject] ([TS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Training.TrainingSchedule(TSC_LAST)] ON [Training].[TrainingSchedule] ([TSC_LAST] ASC);
GO
