USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientInnovationPersonal]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_INNOVATION]   UniqueIdentifier      NOT NULL,
        [DATE]            SmallDateTime         NOT NULL,
        [SURNAME]         NVarChar(512)         NOT NULL,
        [NAME]            NVarChar(512)         NOT NULL,
        [PATRON]          NVarChar(512)         NOT NULL,
        [POSITION]        NVarChar(512)         NOT NULL,
        [NOTE]            NVarChar(Max)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientInnovationPersonal] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientInnovationPersonal(ID_INNOVATION)_dbo.ClientInnovation(ID)] FOREIGN KEY  ([ID_INNOVATION]) REFERENCES [dbo].[ClientInnovation] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientInnovationPersonal(ID_INNOVATION)+(ID,DATE,SURNAME,NAME,PATRON,POSITION,NOTE)] ON [dbo].[ClientInnovationPersonal] ([ID_INNOVATION] ASC) INCLUDE ([ID], [DATE], [SURNAME], [NAME], [PATRON], [POSITION], [NOTE]);
GO
