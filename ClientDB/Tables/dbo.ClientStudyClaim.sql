USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStudyClaim]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_MASTER]      UniqueIdentifier          NULL,
        [ID_CLIENT]      Int                   NOT NULL,
        [DATE]           SmallDateTime         NOT NULL,
        [STUDY_DATE]     SmallDateTime             NULL,
        [CALL_DATE]      SmallDateTime             NULL,
        [NOTE]           NVarChar(Max)         NOT NULL,
        [REPEAT]         Bit                   NOT NULL,
        [ID_TEACHER]     Int                       NULL,
        [TEACHER_NOTE]   NVarChar(Max)             NULL,
        [MEETING_DATE]   DateTime                  NULL,
        [MEETING_NOTE]   NVarChar(Max)             NULL,
        [STATUS]         TinyInt               NOT NULL,
        [UPD_USER]       NVarChar(256)         NOT NULL,
        [UPD_DATE]       DateTime              NOT NULL,
        CONSTRAINT [PK_dbo.ClientStudyClaim] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyClaim(ID_MASTER)_dbo.ClientStudyClaim(ID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientStudyClaim] ([ID]),
        CONSTRAINT [FK_dbo.ClientStudyClaim(ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientStudyClaim(ID_TEACHER)_dbo.TeacherTable(TeacherID)] FOREIGN KEY  ([ID_TEACHER]) REFERENCES [dbo].[TeacherTable] ([TeacherID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyClaim(ID_CLIENT,STATUS,DATE,UPD_USER)+(MEETING_DATE,MEETING_NOTE)] ON [dbo].[ClientStudyClaim] ([ID_CLIENT] ASC, [STATUS] ASC, [DATE] ASC, [UPD_USER] ASC) INCLUDE ([MEETING_DATE], [MEETING_NOTE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStudyClaim(ID_MASTER)+(UPD_USER,UPD_DATE)] ON [dbo].[ClientStudyClaim] ([ID_MASTER] ASC) INCLUDE ([UPD_USER], [UPD_DATE]);
GO
