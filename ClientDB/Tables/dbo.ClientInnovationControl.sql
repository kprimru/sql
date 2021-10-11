USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientInnovationControl]
(
        [ID]              UniqueIdentifier      NOT NULL,
        [ID_INNOVATION]   UniqueIdentifier          NULL,
        [ID_PERSONAL]     UniqueIdentifier          NULL,
        [DATE]            SmallDateTime         NOT NULL,
        [AUDITOR]         NVarChar(512)         NOT NULL,
        [SURNAME]         NVarChar(512)         NOT NULL,
        [NAME]            NVarChar(512)         NOT NULL,
        [PATRON]          NVarChar(512)         NOT NULL,
        [NOTE]            NVarChar(Max)         NOT NULL,
        [RESULT]          TinyInt               NOT NULL,
        CONSTRAINT [PK_dbo.ClientInnovationControl] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientInnovationControl(ID_PERSONAL)_dbo.ClientInnovationPersonal(ID)] FOREIGN KEY  ([ID_PERSONAL]) REFERENCES [dbo].[ClientInnovationPersonal] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientInnovationControl(ID_INNOVATION)] ON [dbo].[ClientInnovationControl] ([ID_INNOVATION] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientInnovationControl(ID_PERSONAL)+(DATE,AUDITOR,SURNAME,NAME,PATRON,NOTE,RESULT)] ON [dbo].[ClientInnovationControl] ([ID_PERSONAL] ASC) INCLUDE ([DATE], [AUDITOR], [SURNAME], [NAME], [PATRON], [NOTE], [RESULT]);
GO
