USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VMIReportHistoryTable]
(
        [VRH_ID]          Int             Identity(1,1)   NOT NULL,
        [VRH_ID_PERIOD]   SmallInt                        NOT NULL,
        [VRH_RIC_NUM]     TinyInt                         NOT NULL,
        [VRH_TO_NUM]      Int                             NOT NULL,
        [VRH_TO_NAME]     VarChar(500)                    NOT NULL,
        [VRH_INN]         VarChar(50)                     NOT NULL,
        [VRH_REGION]      TinyInt                             NULL,
        [VRH_CITY]        VarChar(50)                         NULL,
        [VRH_ADDR]        VarChar(200)                        NULL,
        [VRH_FIO_1]       VarChar(100)                        NULL,
        [VRH_JOB_1]       VarChar(100)                        NULL,
        [VRH_TELS_1]      VarChar(100)                        NULL,
        [VRH_FIO_2]       VarChar(100)                        NULL,
        [VRH_JOB_2]       VarChar(100)                        NULL,
        [VRH_TELS_2]      VarChar(100)                        NULL,
        [VRH_FIO_3]       VarChar(100)                        NULL,
        [VRH_JOB_3]       VarChar(100)                        NULL,
        [VRH_TELS_3]      VarChar(100)                        NULL,
        [VRH_FIO_4]       VarChar(100)                        NULL,
        [VRH_JOB_4]       VarChar(100)                        NULL,
        [VRH_TELS_4]      VarChar(100)                        NULL,
        [VRH_FIO_5]       VarChar(100)                        NULL,
        [VRH_JOB_5]       VarChar(100)                        NULL,
        [VRH_TELS_5]      VarChar(100)                        NULL,
        [VRH_SERV]        VarChar(50)                         NULL,
        [VRH_DISTR]       VarChar(1000)                       NULL,
        [VRH_COMMENT]     VarChar(100)                        NULL,
        CONSTRAINT [PK_dbo.VMIReportHistoryTable] PRIMARY KEY CLUSTERED ([VRH_ID]),
        CONSTRAINT [FK_dbo.VMIReportHistoryTable(VRH_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([VRH_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.VMIReportHistoryTable(VRH_ID_PERIOD)] ON [dbo].[VMIReportHistoryTable] ([VRH_ID_PERIOD] ASC);
GO
