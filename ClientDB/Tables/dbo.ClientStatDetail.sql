USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStatDetail]
(
        [id]                   Int                Identity(1,1)   NOT NULL,
        [UpDate]               DateTime                           NOT NULL,
        [WeekId]               UniqueIdentifier                   NOT NULL,
        [HostId]               Int                                NOT NULL,
        [Distr]                Int                                NOT NULL,
        [Comp]                 TinyInt                            NOT NULL,
        [Net]                  NVarChar(512)                      NOT NULL,
        [UserCount]            Int                                NOT NULL,
        [EnterSum]             Int                                NOT NULL,
        [0Enter]               Int                                NOT NULL,
        [1Enter]               Int                                NOT NULL,
        [2Enter]               Int                                NOT NULL,
        [3Enter]               Int                                NOT NULL,
        [SessionTimeSum]       Int                                NOT NULL,
        [SessionTimeAVG]       float                              NOT NULL,
        [EnterDelta]           VarChar(100)                           NULL,
        [BusySessionCount]     VarChar(100)                           NULL,
        [FreeSpaceRate]        VarChar(100)                           NULL,
        [FreeSpaceRequired]    VarChar(100)                           NULL,
        [FreeSpaceAvailable]   VarChar(100)                           NULL,
        CONSTRAINT [PK_dbo.ClientStatDetail] PRIMARY KEY CLUSTERED ([id]),
        CONSTRAINT [FK_dbo.ClientStatDetail(HostId)_dbo.Hosts(HostID)] FOREIGN KEY  ([HostId]) REFERENCES [dbo].[Hosts] ([HostID]),
        CONSTRAINT [FK_dbo.ClientStatDetail(WeekId)_dbo.Period(ID)] FOREIGN KEY  ([WeekId]) REFERENCES [Common].[Period] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(Distr,HostId,Comp)+INCL] ON [dbo].[ClientStatDetail] ([Distr] ASC, [HostId] ASC, [Comp] ASC) INCLUDE ([WeekId], [Net], [UserCount], [EnterSum], [0Enter], [1Enter], [2Enter], [3Enter], [SessionTimeSum], [SessionTimeAVG], [UpDate]);
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIndex-20220927-114306] ON [dbo].[ClientStatDetail] ([Distr] ASC, [WeekId] ASC, [HostId] ASC, [Comp] ASC);
GO
