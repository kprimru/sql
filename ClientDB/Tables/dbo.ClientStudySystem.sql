USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudySystem]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_STUDY]    UniqueIdentifier      NOT NULL,
        [ID_SYSTEM]   Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientStudySystem] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudySystem(ID_STUDY)_dbo.ClientStudy(ID)] FOREIGN KEY  ([ID_STUDY]) REFERENCES [dbo].[ClientStudy] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudySystem(ID_SYSTEM)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientStudySystem(ID_STUDY,ID_SYSTEM)] ON [dbo].[ClientStudySystem] ([ID_STUDY] ASC, [ID_SYSTEM] ASC);
GO
