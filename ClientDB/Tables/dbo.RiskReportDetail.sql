USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RiskReportDetail]
(
        [Id]                     bigint          Identity(1,1)   NOT NULL,
        [Report_Id]              Int                             NOT NULL,
        [RN]                     SmallInt                        NOT NULL,
        [ClientID]               Int                                 NULL,
        [ClientFullName]         VarChar(512)                        NULL,
        [ServiceTypeShortName]   VarChar(64)                         NULL,
        [ServiceName]            VarChar(256)                        NULL,
        [ManagerName]            VarChar(256)                        NULL,
        [Distrs]                 VarChar(Max)                        NULL,
        [Complect]               VarChar(128)                        NULL,
        [DutyCount]              SmallInt                            NULL,
        [DutyQuestionCount]      SmallInt                            NULL,
        [DutyHotlineCount]       SmallInt                            NULL,
        [RivalCount]             SmallInt                            NULL,
        [StudyCount]             SmallInt                            NULL,
        [SeminarCount]           SmallInt                            NULL,
        [UpdatesCount]           SmallInt                            NULL,
        [LostCount]              SmallInt                            NULL,
        [DownloadCount]          SmallInt                            NULL,
        [DownloadBases]          VarChar(512)                        NULL,
        [OnlineActivityCount]    SmallInt                            NULL,
        [OfflineEnterCount]      SmallInt                            NULL,
        [OldRes]                 VarChar(128)                        NULL,
        [OldConsExe]             VarChar(128)                        NULL,
        [ComplianceIB]           VarChar(512)                        NULL,
        [DeliveryCount]          SmallInt                            NULL,
        [OldEvent]               SmallDateTime                       NULL,
        [LastPay]                VarChar(64)                         NULL,
        CONSTRAINT [PK__RiskRepo__3214EC06F9D2086B] PRIMARY KEY NONCLUSTERED ([Id])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.RiskReportDetail(Report_Id,RN,ClientID)] ON [dbo].[RiskReportDetail] ([Report_Id] ASC, [RN] ASC, [ClientID] ASC);
GO
