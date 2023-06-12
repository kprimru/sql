USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudySaleRivals]
(
        [StudySale_Id]   UniqueIdentifier      NOT NULL,
        [RivalType_Id]   Int                   NOT NULL,
        CONSTRAINT [PK_dbo.StudySaleRivals] PRIMARY KEY CLUSTERED ([StudySale_Id],[RivalType_Id]),
        CONSTRAINT [FK_dbo.StudySaleRivals(StudySale_Id)_dbo.StudySale(ID)] FOREIGN KEY  ([StudySale_Id]) REFERENCES [dbo].[StudySale] ([ID]),
        CONSTRAINT [FK_dbo.StudySaleRivals(RivalType_Id)_dbo.RivalTypeTable(RivalTypeID)] FOREIGN KEY  ([RivalType_Id]) REFERENCES [dbo].[RivalTypeTable] ([RivalTypeID])
);
GO
