USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[PersonalType]
(
        [PTMS_ID]     UniqueIdentifier      NOT NULL,
        [PTMS_LAST]   DateTime              NOT NULL,
        CONSTRAINT [PK_PersonalType_1] PRIMARY KEY CLUSTERED ([PTMS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_PTMS_LAST] ON [Personal].[PersonalType] ([PTMS_LAST] DESC);
GO
