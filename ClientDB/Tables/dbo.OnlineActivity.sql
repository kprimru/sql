USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OnlineActivity]
(
        [Id]             Int                Identity(1,1)   NOT NULL,
        [ID_WEEK]        UniqueIdentifier                   NOT NULL,
        [ID_HOST]        Int                                NOT NULL,
        [DISTR]          Int                                NOT NULL,
        [COMP]           TinyInt                            NOT NULL,
        [LGN]            NVarChar(512)                      NOT NULL,
        [ACTIVITY]       Bit                                NOT NULL,
        [LOGIN_CNT]      SmallInt                               NULL,
        [SESSION_TIME]   SmallInt                               NULL,
        [UPD_DATE]       DateTime                           NOT NULL,
        [Email]          VarChar(256)                           NULL,
        [FIO]            VarChar(256)                           NULL,
        CONSTRAINT [PK_dbo.OnlineActivity] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_dbo.OnlineActivity(ID_WEEK)_dbo.Period(ID)] FOREIGN KEY  ([ID_WEEK]) REFERENCES [Common].[Period] ([ID]),
        CONSTRAINT [FK_dbo.OnlineActivity(ID_HOST)_dbo.Hosts(HostID)] FOREIGN KEY  ([ID_HOST]) REFERENCES [dbo].[Hosts] ([HostID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.OnlineActivity(ID_HOST,DISTR,COMP)+(ID_WEEK,LGN,ACTIVITY)] ON [dbo].[OnlineActivity] ([ID_HOST] ASC, [DISTR] ASC, [COMP] ASC) INCLUDE ([ID_WEEK], [LGN], [ACTIVITY]);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.OnlineActivity(ID_WEEK,LGN)+(ID_HOST,DISTR,COMP,ACTIVITY,LOGIN_CNT,SESSION_TIME)] ON [dbo].[OnlineActivity] ([ID_WEEK] ASC, [LGN] ASC) INCLUDE ([ID_HOST], [DISTR], [COMP], [ACTIVITY], [LOGIN_CNT], [SESSION_TIME]);
GO
