USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDutyNotify]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_MASTER]     UniqueIdentifier          NULL,
        [ID_DUTY]       Int                   NOT NULL,
        [NOTIFY]        TinyInt               NOT NULL,
        [NOTIFY_NOTE]   NVarChar(Max)         NOT NULL,
        [NOTIFY_TYPE]   TinyInt               NOT NULL,
        [STATUS]        TinyInt               NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientDutyNotify] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientDutyNotify(ID_DUTY)_dbo.ClientDutyTable(ClientDutyID)] FOREIGN KEY  ([ID_DUTY]) REFERENCES [dbo].[ClientDutyTable] ([ClientDutyID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyNotify(ID_DUTY,STATUS)+(NOTIFY,UPD_DATE,UPD_USER)] ON [dbo].[ClientDutyNotify] ([ID_DUTY] ASC, [STATUS] ASC) INCLUDE ([NOTIFY], [UPD_DATE], [UPD_USER]);
GO
