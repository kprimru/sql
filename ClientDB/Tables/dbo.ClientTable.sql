USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTable]
(
        [ClientID]             Int                Identity(1,1)   NOT NULL,
        [ClientShortName]      VarChar(100)                           NULL,
        [ClientFullName]       VarChar(250)                       NOT NULL,
        [ClientINN]            VarChar(50)                            NULL,
        [ClientServiceID]      Int                                    NULL,
        [ClientActivity]       VarChar(Max)                           NULL,
        [ClientDayBegin]       VarChar(20)                            NULL,
        [ClientDayEnd]         VarChar(20)                            NULL,
        [DayID]                Int                                    NULL,
        [ServiceStart]         DateTime                               NULL,
        [ServiceTime]          Int                                    NULL,
        [PayTypeID]            Int                                    NULL,
        [ClientMainBook]       Int                                NOT NULL,
        [ClientNewspaper]      Int                                NOT NULL,
        [StatusID]             Int                                NOT NULL,
        [ClientNote]           VarChar(Max)                           NULL,
        [ServiceTypeID]        Int                                NOT NULL,
        [RangeID]              Int                                NOT NULL,
        [OriClient]            Bit                                    NULL,
        [ClientEmail]          VarChar(200)                           NULL,
        [ClientLastUpdate]     DateTime                               NULL,
        [ClientPlace]          VarChar(Max)                           NULL,
        [ClientLast]           DateTime                           NOT NULL,
        [PurchaseTypeID]       UniqueIdentifier                       NULL,
        [ClientOfficial]       VarChar(500)                           NULL,
        [DinnerBegin]          VarChar(20)                            NULL,
        [DinnerEnd]            VarChar(20)                            NULL,
        [ID_MASTER]            Int                                    NULL,
        [STATUS]               TinyInt                            NOT NULL,
        [UPD_USER]             NVarChar(256)                      NOT NULL,
        [ID_HEAD]              Int                                    NULL,
        [HST_CHECK]            Bit                                    NULL,
        [STT_CHECK]            Bit                                    NULL,
        [USR_CHECK]            Bit                                    NULL,
        [ClientVisitCountID]   SmallInt                               NULL,
        [INET_CHECK]           Bit                                    NULL,
        [IsLarge]              Bit                                    NULL,
        [IsDebtor]             Bit                                    NULL,
        [ClientTypeId]         TinyInt                                NULL,
        [ClientKind_Id]        SmallInt                               NULL,
        CONSTRAINT [PK_dbo.ClientTable] PRIMARY KEY NONCLUSTERED ([ClientID]),
        CONSTRAINT [FK_dbo.ClientTable(ID_MASTER)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientTable(ID_HEAD)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([ID_HEAD]) REFERENCES [dbo].[ClientTable] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientTable(DayID)_dbo.DayTable(DayID)] FOREIGN KEY  ([DayID]) REFERENCES [dbo].[DayTable] ([DayID]),
        CONSTRAINT [FK_dbo.ClientTable(ClientServiceID)_dbo.ServiceTable(ServiceID)] FOREIGN KEY  ([ClientServiceID]) REFERENCES [dbo].[ServiceTable] ([ServiceID]),
        CONSTRAINT [FK_dbo.ClientTable(StatusID)_dbo.ServiceStatusTable(ServiceStatusID)] FOREIGN KEY  ([StatusID]) REFERENCES [dbo].[ServiceStatusTable] ([ServiceStatusID]),
        CONSTRAINT [FK_dbo.ClientTable(ClientTypeId)_dbo.ClientTypeTable(ClientTypeID)] FOREIGN KEY  ([ClientTypeId]) REFERENCES [dbo].[ClientTypeTable] ([ClientTypeID]),
        CONSTRAINT [FK_dbo.ClientTable(ClientKind_Id)_dbo.ClientKind(Id)] FOREIGN KEY  ([ClientKind_Id]) REFERENCES [dbo].[ClientKind] ([Id]),
        CONSTRAINT [FK_dbo.ClientTable(PayTypeID)_dbo.PayTypeTable(PayTypeID)] FOREIGN KEY  ([PayTypeID]) REFERENCES [dbo].[PayTypeTable] ([PayTypeID]),
        CONSTRAINT [FK_dbo.ClientTable(RangeID)_dbo.RangeTable(RangeID)] FOREIGN KEY  ([RangeID]) REFERENCES [dbo].[RangeTable] ([RangeID]),
        CONSTRAINT [FK_dbo.ClientTable(ServiceTypeID)_dbo.ServiceTypeTable(ServiceTypeID)] FOREIGN KEY  ([ServiceTypeID]) REFERENCES [dbo].[ServiceTypeTable] ([ServiceTypeID]),
        CONSTRAINT [FK_dbo.ClientTable(ClientVisitCountID)_dbo.ClientVisitCount(ID)] FOREIGN KEY  ([ClientVisitCountID]) REFERENCES [dbo].[ClientVisitCount] ([ID]),
        CONSTRAINT [FK_dbo.ClientTable(PurchaseTypeID)_dbo.PurchaseType(PT_ID)] FOREIGN KEY  ([PurchaseTypeID]) REFERENCES [Purchase].[PurchaseType] ([PT_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientTable(ClientID)] ON [dbo].[ClientTable] ([ClientID] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(ClientLast,ID_MASTER)] ON [dbo].[ClientTable] ([ClientLast] ASC, [ID_MASTER] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(ClientServiceID,STATUS)] ON [dbo].[ClientTable] ([ClientServiceID] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(ID_MASTER)+(ClientFullName,ClientINN,ClientLast,UPD_USER,ClientShortName,STATUS)] ON [dbo].[ClientTable] ([ID_MASTER] ASC) INCLUDE ([ClientFullName], [ClientINN], [ClientLast], [UPD_USER], [ClientShortName], [STATUS]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(OriClient,STATUS)] ON [dbo].[ClientTable] ([OriClient] ASC, [STATUS] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(STATUS)+INCL] ON [dbo].[ClientTable] ([STATUS] ASC) INCLUDE ([ClientID], [ClientServiceID], [StatusID], [ServiceTypeID], [OriClient], [IsLarge], [ClientTypeId], [ClientKind_Id]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(STATUS,ClientFullName)+(ClientShortName,ID_MASTER)] ON [dbo].[ClientTable] ([STATUS] ASC, [ClientFullName] ASC) INCLUDE ([ClientShortName], [ID_MASTER]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(STATUS,ClientOfficial)] ON [dbo].[ClientTable] ([STATUS] ASC, [ClientOfficial] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(STATUS,ClientShortName)] ON [dbo].[ClientTable] ([STATUS] ASC, [ClientShortName] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(STATUS,ID_HEAD)] ON [dbo].[ClientTable] ([STATUS] ASC, [ID_HEAD] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(StatusID,STATUS)+INCL] ON [dbo].[ClientTable] ([StatusID] ASC, [STATUS] ASC) INCLUDE ([ClientServiceID], [ClientFullName], [DayID], [ServiceStart], [ServiceTypeID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientTable(StatusID,STATUS,ServiceStart,ServiceTime)+INCL] ON [dbo].[ClientTable] ([StatusID] ASC, [STATUS] ASC, [ServiceStart] ASC, [ServiceTime] ASC) INCLUDE ([ClientShortName], [ClientFullName], [ClientServiceID], [DayID]);
GO
GRANT SELECT ON [dbo].[ClientTable] TO BL_READER;
GRANT SELECT ON [dbo].[ClientTable] TO claim_view;
GO
