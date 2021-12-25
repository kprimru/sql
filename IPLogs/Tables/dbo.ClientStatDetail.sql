USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientStatDetail]
(
        [CSD_ID]                 bigint          Identity(1,1)   NOT NULL,
        [CSD_ID_CS]              Int                             NOT NULL,
        [CSD_NUM]                bigint                          NOT NULL,
        [CSD_SYS]                SmallInt                        NOT NULL,
        [CSD_DISTR]              Int                             NOT NULL,
        [CSD_COMP]               SmallInt                        NOT NULL,
        [CSD_IP]                 NVarChar(100)                   NOT NULL,
        [CSD_SESSION]            NVarChar(100)                   NOT NULL,
        [CSD_START]              DateTime                            NULL,
        [CSD_MONTH]               AS (dateadd(day,(1)-datepart(day,CONVERT([smalldatetime],CONVERT([varchar](20),isnull([CSD_START],[CSD_END]),(112)),(112))),CONVERT([smalldatetime],CONVERT([varchar](20),isnull([CSD_START],[CSD_END]),(112)),(112)))) PERSISTED,
        [CSD_DAY]                 AS (CONVERT([smalldatetime],CONVERT([varchar](20),isnull([CSD_START],[CSD_END]),(112)),(112))) PERSISTED,
        [CSD_QST_TIME]           SmallInt                        NOT NULL,
        [CSD_QST_SIZE]           bigint                          NOT NULL,
        [CSD_ANS_TIME]           SmallInt                        NOT NULL,
        [CSD_ANS_SIZE]           bigint                          NOT NULL,
        [CSD_CACHE_TIME]         SmallInt                        NOT NULL,
        [CSD_CACHE_SIZE]         bigint                          NOT NULL,
        [CSD_DOWNLOAD_TIME]      Int                             NOT NULL,
        [CSD_UPDATE_TIME]        Int                             NOT NULL,
        [CSD_REPORT_TIME]        SmallInt                        NOT NULL,
        [CSD_REPORT_SIZE]        bigint                          NOT NULL,
        [CSD_END]                DateTime                            NULL,
        [CSD_REDOWNLOAD]         Bit                             NOT NULL,
        [CSD_LOG_PATH]           NVarChar(512)                   NOT NULL,
        [CSD_LOG_FILE]           NVarChar(512)                   NOT NULL,
        [CSD_LOG_RESULT]         NVarChar(512)                   NOT NULL,
        [CSD_LOG_LETTER]         NVarChar(512)                   NOT NULL,
        [CSD_USR]                NVarChar(512)                   NOT NULL,
        [CSD_CODE_CLIENT]        Int                             NOT NULL,
        [CSD_CODE_SERVER]        Int                             NOT NULL,
        [CSD_IP_MODE]            NVarChar(128)                   NOT NULL,
        [CSD_RES_VERSION]        NVarChar(128)                       NULL,
        [CSD_DOWNLOAD_SPEED]     bigint                              NULL,
        [CSD_STT_SEND]           Bit                                 NULL,
        [CSD_STT_RESULT]         Bit                                 NULL,
        [CSD_INET_EXT]           Bit                                 NULL,
        [CSD_PROXY_METOD]        NVarChar(256)                       NULL,
        [CSD_PROXY_INTERFACE]    NVarChar(256)                       NULL,
        [CSD_START_WITHOUT_MS]    AS (dateadd(millisecond, -datepart(millisecond,[CSD_START]),[CSD_START])) PERSISTED,
        CONSTRAINT [PK_dbo.ClientStatDetail] PRIMARY KEY CLUSTERED ([CSD_ID]),
        CONSTRAINT [FK_dbo.ClientStatDetail(CSD_ID_CS)_dbo.ClientStat(CS_ID)] FOREIGN KEY  ([CSD_ID_CS]) REFERENCES [dbo].[ClientStat] ([CS_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_DISTR,CSD_COMP)+INCL] ON [dbo].[ClientStatDetail] ([CSD_DISTR] ASC, [CSD_COMP] ASC) INCLUDE ([CSD_ID], [CSD_ID_CS], [CSD_SYS], [CSD_IP], [CSD_SESSION], [CSD_START], [CSD_QST_TIME], [CSD_QST_SIZE], [CSD_ANS_TIME], [CSD_ANS_SIZE], [CSD_CACHE_TIME], [CSD_CACHE_SIZE], [CSD_DOWNLOAD_TIME], [CSD_UPDATE_TIME], [CSD_REPORT_TIME], [CSD_REPORT_SIZE], [CSD_END], [CSD_REDOWNLOAD], [CSD_LOG_PATH], [CSD_LOG_FILE], [CSD_LOG_RESULT], [CSD_LOG_LETTER], [CSD_USR], [CSD_CODE_CLIENT], [CSD_CODE_SERVER], [CSD_IP_MODE], [CSD_RES_VERSION], [CSD_DOWNLOAD_SPEED], [CSD_STT_SEND], [CSD_STT_RESULT], [CSD_INET_EXT], [CSD_START_WITHOUT_MS]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_DISTR,CSD_COMP,CSD_STT_SEND,CSD_STT_RESULT)+(CSD_SYS)] ON [dbo].[ClientStatDetail] ([CSD_DISTR] ASC, [CSD_COMP] ASC, [CSD_STT_SEND] ASC, [CSD_STT_RESULT] ASC) INCLUDE ([CSD_SYS]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_DISTR,CSD_COMP,CSD_SYS,CSD_STT_SEND,CSD_STT_RESULT,CSD_START,CSD_END)] ON [dbo].[ClientStatDetail] ([CSD_DISTR] ASC, [CSD_COMP] ASC, [CSD_SYS] ASC, [CSD_STT_SEND] ASC, [CSD_STT_RESULT] ASC, [CSD_START] ASC, [CSD_END] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_DISTR,CSD_SYS,CSD_COMP,CSD_START,CSD_END)+(CSD_ID)] ON [dbo].[ClientStatDetail] ([CSD_DISTR] ASC, [CSD_SYS] ASC, [CSD_COMP] ASC, [CSD_START] ASC, [CSD_END] ASC) INCLUDE ([CSD_ID]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_ID_CS)+(CSD_SYS,CSD_DISTR,CSD_COMP,CSD_MONTH,CSD_DAY)] ON [dbo].[ClientStatDetail] ([CSD_ID_CS] ASC) INCLUDE ([CSD_SYS], [CSD_DISTR], [CSD_COMP], [CSD_MONTH], [CSD_DAY]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_ID_CS)+INCL] ON [dbo].[ClientStatDetail] ([CSD_ID_CS] ASC) INCLUDE ([CSD_MONTH], [CSD_DAY], [CSD_QST_SIZE], [CSD_ANS_SIZE], [CSD_CACHE_SIZE], [CSD_REPORT_SIZE]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_ID_CS,CSD_NUM)] ON [dbo].[ClientStatDetail] ([CSD_ID_CS] ASC, [CSD_NUM] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_START)+(CSD_SYS,CSD_DISTR,CSD_COMP)] ON [dbo].[ClientStatDetail] ([CSD_START] ASC) INCLUDE ([CSD_SYS], [CSD_DISTR], [CSD_COMP]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_STT_SEND,CSD_STT_RESULT)+(CSD_SYS,CSD_DISTR,CSD_COMP,CSD_START,CSD_END)] ON [dbo].[ClientStatDetail] ([CSD_STT_SEND] ASC, [CSD_STT_RESULT] ASC) INCLUDE ([CSD_SYS], [CSD_DISTR], [CSD_COMP], [CSD_START], [CSD_END]);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientStatDetail(CSD_SYS,CSD_DISTR)+(CSD_DAY,CSD_CODE_CLIENT,CSD_CODE_SERVER)] ON [dbo].[ClientStatDetail] ([CSD_SYS] ASC, [CSD_DISTR] ASC) INCLUDE ([CSD_DAY], [CSD_CODE_CLIENT], [CSD_CODE_SERVER]);
GO
