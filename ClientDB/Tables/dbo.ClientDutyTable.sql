USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientDutyTable]
(
        [ClientDutyID]             Int                Identity(1,1)   NOT NULL,
        [ID_MASTER]                Int                                    NULL,
        [ClientID]                 Int                                NOT NULL,
        [ClientDutyDateTime]       DateTime                               NULL,
        [ClientDutyDate]           VarChar(20)                            NULL,
        [ClientDutyTime]           VarChar(20)                            NULL,
        [ClientDutyContact]        VarChar(150)                           NULL,
        [ClientDutySurname]        VarChar(250)                           NULL,
        [ClientDutyName]           VarChar(250)                           NULL,
        [ClientDutyPatron]         VarChar(250)                           NULL,
        [ClientDutyPos]            VarChar(50)                        NOT NULL,
        [ClientDutyPhone]          VarChar(50)                        NOT NULL,
        [DutyID]                   Int                                NOT NULL,
        [ManagerID]                Int                                    NULL,
        [CallTypeID]               Int                                    NULL,
        [ClientDutyQuest]          VarChar(Max)                       NOT NULL,
        [ClientDutyDocs]           Int                                    NULL,
        [ClientDutyNPO]            Bit                                NOT NULL,
        [ClientDutyComplete]       Bit                                NOT NULL,
        [ClientDutyComment]        VarChar(Max)                       NOT NULL,
        [ClientDutyUncomplete]     Bit                                    NULL,
        [ClientDutyGive]           VarChar(100)                           NULL,
        [ClientDutyAnswer]         DateTime                               NULL,
        [ClientDutyClaimDate]      SmallDateTime                          NULL,
        [ClientDutyClaimNum]       VarChar(50)                            NULL,
        [ClientDutyClaimAnswer]    SmallDateTime                          NULL,
        [ClientDutyClaimComment]   VarChar(500)                           NULL,
        [ID_GRANT_TYPE]            UniqueIdentifier                       NULL,
        [CREATE_DATE]              DateTime                               NULL,
        [CREATE_USER]              NVarChar(256)                          NULL,
        [UPDATE_DATE]              DateTime                               NULL,
        [UPDATE_USER]              NVarChar(256)                          NULL,
        [STATUS]                   TinyInt                            NOT NULL,
        [UPD_DATE]                 DateTime                           NOT NULL,
        [UPD_USER]                 NVarChar(256)                      NOT NULL,
        [ID_DIRECTION]             UniqueIdentifier                       NULL,
        [EMAIL]                    NVarChar(256)                          NULL,
        [LINK]                     Bit                                    NULL,
        CONSTRAINT [PK_dbo.ClientDutyTable] PRIMARY KEY NONCLUSTERED ([ClientDutyID]),
        CONSTRAINT [FK_dbo.ClientDutyTable(ID_GRANT_TYPE)_dbo.DocumentGrantType(ID)] FOREIGN KEY  ([ID_GRANT_TYPE]) REFERENCES [dbo].[DocumentGrantType] ([ID]),
        CONSTRAINT [FK_dbo.ClientDutyTable(DutyID)_dbo.DutyTable(DutyID)] FOREIGN KEY  ([DutyID]) REFERENCES [dbo].[DutyTable] ([DutyID]),
        CONSTRAINT [FK_dbo.ClientDutyTable(ManagerID)_dbo.ManagerTable(ManagerID)] FOREIGN KEY  ([ManagerID]) REFERENCES [dbo].[ManagerTable] ([ManagerID]),
        CONSTRAINT [FK_dbo.ClientDutyTable(ClientID)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ClientID]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientDutyTable(CallTypeID)_dbo.CallTypeTable(CallTypeID)] FOREIGN KEY  ([CallTypeID]) REFERENCES [dbo].[CallTypeTable] ([CallTypeID]),
        CONSTRAINT [FK_dbo.ClientDutyTable(ID_DIRECTION)_dbo.CallDirection(ID)] FOREIGN KEY  ([ID_DIRECTION]) REFERENCES [dbo].[CallDirection] ([ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientDutyTable(ClientID,ClientDutyID)] ON [dbo].[ClientDutyTable] ([ClientID] ASC, [ClientDutyID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyTable(ClientDutyComplete,STATUS)+(ClientDutyDateTime,DutyID,CallTypeID,ClientDutyNPO,ClientDutyComment,ID_DIREC] ON [dbo].[ClientDutyTable] ([ClientDutyComplete] ASC, [STATUS] ASC) INCLUDE ([ClientDutyDateTime], [DutyID], [CallTypeID], [ClientDutyNPO], [ClientDutyComment], [ID_DIRECTION]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientDutyTable(ClientDutyDateTime,STATUS)+(ClientDutyID)] ON [dbo].[ClientDutyTable] ([ClientDutyDateTime] ASC, [STATUS] ASC) INCLUDE ([ClientDutyID]);
GO
