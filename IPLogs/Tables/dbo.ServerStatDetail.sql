USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerStatDetail]
(
        [SSD_ID]             bigint          Identity(1,1)   NOT NULL,
        [SSD_ID_SD]          Int                             NOT NULL,
        [SSD_NUM]            bigint                          NOT NULL,
        [SSD_DATE]           DateTime                        NOT NULL,
        [SSD_MONTH]           AS (dateadd(day,(1)-datepart(day,CONVERT([smalldatetime],CONVERT([varchar](20),[SSD_DATE],(112)),(112))),CONVERT([smalldatetime],CONVERT([varchar](20),[SSD_DATE],(112)),(112)))) PERSISTED,
        [SSD_DAY]             AS (CONVERT([smalldatetime],CONVERT([varchar](20),[SSD_DATE],(112)),(112))) PERSISTED,
        [SSD_HOSTCOUNT]      SmallInt                        NOT NULL,
        [SSD_QUERY]          SmallInt                        NOT NULL,
        [SSD_SESSIONCOUNT]   SmallInt                        NOT NULL,
        [SSD_TRAFIN]         bigint                          NOT NULL,
        [SSD_TRAFOUT]        bigint                          NOT NULL,
        CONSTRAINT [PK_dbo.ServerStatDetail] PRIMARY KEY CLUSTERED ([SSD_ID]),
        CONSTRAINT [FK_dbo.ServerStatDetail(SSD_ID_SD)_dbo.ServerStat(SS_ID)] FOREIGN KEY  ([SSD_ID_SD]) REFERENCES [dbo].[ServerStat] ([SS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ServerStatDetail(SSD_ID_SD,SSD_NUM)+(SSD_MONTH,SSD_DAY,SSD_TRAFIN,SSD_TRAFOUT)] ON [dbo].[ServerStatDetail] ([SSD_ID_SD] ASC, [SSD_NUM] ASC) INCLUDE ([SSD_MONTH], [SSD_DAY], [SSD_TRAFIN], [SSD_TRAFOUT]);
GO
