USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientRival]
(
        [CR_ID]             Int             Identity(1,1)   NOT NULL,
        [CR_ID_MASTER]      Int                                 NULL,
        [CL_ID]             Int                             NOT NULL,
        [CR_DATE]           SmallDateTime                   NOT NULL,
        [CR_ID_TYPE]        Int                                 NULL,
        [CR_ID_STATUS]      Int                                 NULL,
        [CR_COMPLETE]       Bit                             NOT NULL,
        [CR_CONTROL]        Bit                             NOT NULL,
        [CR_CONTROL_DATE]   SmallDateTime                       NULL,
        [CR_CONDITION]      VarChar(Max)                        NULL,
        [CR_SURNAME]        NVarChar(512)                       NULL,
        [CR_NAME]           NVarChar(512)                       NULL,
        [CR_PATRON]         NVarChar(512)                       NULL,
        [CR_PHONE]          NVarChar(512)                       NULL,
        [CR_ACTIVE]         Bit                             NOT NULL,
        [CR_CREATE_DATE]    DateTime                        NOT NULL,
        [CR_CREATE_USER]    NVarChar(256)                   NOT NULL,
        [CR_UPDATE_DATE]    DateTime                        NOT NULL,
        [CR_UPDATE_USER]    NVarChar(256)                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientRival] PRIMARY KEY NONCLUSTERED ([CR_ID]),
        CONSTRAINT [FK_dbo.ClientRival(CR_ID_MASTER)_dbo.ClientRival(CR_ID)] FOREIGN KEY  ([CR_ID_MASTER]) REFERENCES [dbo].[ClientRival] ([CR_ID]),
        CONSTRAINT [FK_dbo.ClientRival(CL_ID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CL_ID]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientRival(CR_ID_TYPE)_dbo.RivalTypeTable(RivalTypeID)] FOREIGN KEY  ([CR_ID_TYPE]) REFERENCES [dbo].[RivalTypeTable] ([RivalTypeID]),
        CONSTRAINT [FK_dbo.ClientRival(CR_ID_STATUS)_dbo.RivalStatus(RS_ID)] FOREIGN KEY  ([CR_ID_STATUS]) REFERENCES [dbo].[RivalStatus] ([RS_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientRival(CL_ID,CR_DATE,CR_ID)] ON [dbo].[ClientRival] ([CL_ID] ASC, [CR_DATE] ASC, [CR_ID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientRival(CR_ACTIVE,CR_DATE)+(CL_ID)] ON [dbo].[ClientRival] ([CR_ACTIVE] ASC, [CR_DATE] ASC) INCLUDE ([CL_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientRival(CR_COMPLETE,CR_ACTIVE)+(CL_ID,CR_DATE,CR_CONTROL_DATE)] ON [dbo].[ClientRival] ([CR_COMPLETE] ASC, [CR_ACTIVE] ASC) INCLUDE ([CL_ID], [CR_DATE], [CR_CONTROL_DATE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientRival(CR_CONTROL,CR_ACTIVE,CR_CONTROL_DATE)+(CL_ID,CR_DATE)] ON [dbo].[ClientRival] ([CR_CONTROL] ASC, [CR_ACTIVE] ASC, [CR_CONTROL_DATE] ASC) INCLUDE ([CL_ID], [CR_DATE]);
GO
