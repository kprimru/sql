USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientRivalPersonal]
(
        [CRP_ID]            Int   Identity(1,1)   NOT NULL,
        [CRP_ID_RIVAL]      Int                   NOT NULL,
        [CRP_ID_PERSONAL]   Int                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientRivalPersonal] PRIMARY KEY NONCLUSTERED ([CRP_ID]),
        CONSTRAINT [FK_dbo.ClientRivalPersonal(CRP_ID_RIVAL)_dbo.ClientRival(CR_ID)] FOREIGN KEY  ([CRP_ID_RIVAL]) REFERENCES [dbo].[ClientRival] ([CR_ID]),
        CONSTRAINT [FK_dbo.ClientRivalPersonal(CRP_ID_PERSONAL)_dbo.PositionTypeTable(PositionTypeID)] FOREIGN KEY  ([CRP_ID_PERSONAL]) REFERENCES [dbo].[PositionTypeTable] ([PositionTypeID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientRivalPersonal(CRP_ID_RIVAL,CRP_ID)] ON [dbo].[ClientRivalPersonal] ([CRP_ID_RIVAL] ASC, [CRP_ID] ASC);
GO
