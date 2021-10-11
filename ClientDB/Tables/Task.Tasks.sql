USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Task].[Tasks]
(
        [ID]           UniqueIdentifier      NOT NULL,
        [ID_MASTER]    UniqueIdentifier          NULL,
        [DATE]         SmallDateTime         NOT NULL,
        [TIME]         DateTime                  NULL,
        [SENDER]       NVarChar(256)         NOT NULL,
        [RECEIVER]     NVarChar(256)             NULL,
        [ID_CLIENT]    Int                       NULL,
        [ID_STATUS]    UniqueIdentifier      NOT NULL,
        [SHORT]        NVarChar(512)         NOT NULL,
        [NOTE]         NVarChar(Max)         NOT NULL,
        [EXPIRE]       SmallDateTime             NULL,
        [EXEC_DATE]    DateTime                  NULL,
        [EXEC_NOTE]    NVarChar(Max)             NULL,
        [NOTIFY]       Bit                   NOT NULL,
        [NOTIFY_DAY]   SmallInt                  NULL,
        [STATUS]       TinyInt               NOT NULL,
        [UPD_DATE]     DateTime              NOT NULL,
        [UPD_USER]     NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Task.Tasks] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Task.Tasks(ID_STATUS)_Task.TaskStatus(ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [Task].[TaskStatus] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Task.Tasks(DATE,STATUS)+(ID,TIME,SENDER,RECEIVER,ID_CLIENT,ID_STATUS,SHORT,NOTE,EXPIRE)] ON [Task].[Tasks] ([DATE] ASC, [STATUS] ASC) INCLUDE ([ID], [TIME], [SENDER], [RECEIVER], [ID_CLIENT], [ID_STATUS], [SHORT], [NOTE], [EXPIRE]);
CREATE NONCLUSTERED INDEX [IX_Task.Tasks(ID_CLIENT,STATUS,SENDER)] ON [Task].[Tasks] ([ID_CLIENT] ASC, [STATUS] ASC, [SENDER] ASC);
GO
