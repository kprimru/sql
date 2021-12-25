﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTable:Log]
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
        CONSTRAINT [PK_dbo.ClientTable:Log] PRIMARY KEY NONCLUSTERED ([ClientID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ClientKind_Id)_dbo.ClientKind(Id)] FOREIGN KEY  ([ClientKind_Id]) REFERENCES [dbo].[ClientKind] ([Id]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ClientServiceID)_dbo.ServiceTable(ServiceID)] FOREIGN KEY  ([ClientServiceID]) REFERENCES [dbo].[ServiceTable] ([ServiceID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ClientTypeId)_dbo.ClientTypeTable(ClientTypeID)] FOREIGN KEY  ([ClientTypeId]) REFERENCES [dbo].[ClientTypeTable] ([ClientTypeID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ClientVisitCountID)_dbo.ClientVisitCount(ID)] FOREIGN KEY  ([ClientVisitCountID]) REFERENCES [dbo].[ClientVisitCount] ([ID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(DayID)_dbo.DayTable(DayID)] FOREIGN KEY  ([DayID]) REFERENCES [dbo].[DayTable] ([DayID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ID_HEAD)_dbo.ClientTable:Log(ClientID)] FOREIGN KEY  ([ID_HEAD]) REFERENCES [dbo].[ClientTable:Log] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ID_MASTER)_dbo.ClientTable:Log(ClientID)] FOREIGN KEY  ([ID_MASTER]) REFERENCES [dbo].[ClientTable:Log] ([ClientID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(PayTypeID)_dbo.PayTypeTable(PayTypeID)] FOREIGN KEY  ([PayTypeID]) REFERENCES [dbo].[PayTypeTable] ([PayTypeID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(PurchaseTypeID)_dbo.PurchaseType(PT_ID)] FOREIGN KEY  ([PurchaseTypeID]) REFERENCES [Purchase].[PurchaseType] ([PT_ID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(RangeID)_dbo.RangeTable(RangeID)] FOREIGN KEY  ([RangeID]) REFERENCES [dbo].[RangeTable] ([RangeID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(ServiceTypeID)_dbo.ServiceTypeTable(ServiceTypeID)] FOREIGN KEY  ([ServiceTypeID]) REFERENCES [dbo].[ServiceTypeTable] ([ServiceTypeID]),
        CONSTRAINT [FK_dbo.ClientTable:Log(StatusID)_dbo.ServiceStatusTable(ServiceStatusID)] FOREIGN KEY  ([StatusID]) REFERENCES [dbo].[ServiceStatusTable] ([ServiceStatusID])
);
GO
