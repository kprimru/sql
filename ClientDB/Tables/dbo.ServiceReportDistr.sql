USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceReportDistr]
(
        [SRD_ID]          UniqueIdentifier      NOT NULL,
        [SRD_ID_SR]       UniqueIdentifier      NOT NULL,
        [SRD_ID_CLIENT]   Int                   NOT NULL,
        [SRD_HST]         Int                   NOT NULL,
        [SRD_HST_NAME]    VarChar(50)           NOT NULL,
        [SRD_HST_ORDER]   Int                   NOT NULL,
        [SRD_SYS]         Int                   NOT NULL,
        [SRD_SYS_NAME]    VarChar(50)           NOT NULL,
        [SRD_NET]         VarChar(50)           NOT NULL,
        [SRD_DIS_STR]     VarChar(50)           NOT NULL,
        [SRD_DIS_NUM]     Int                   NOT NULL,
        [SRD_DIS_COMP]    TinyInt               NOT NULL,
        [SRD_STATUS]      VarChar(50)           NOT NULL,
        CONSTRAINT [PK_dbo.ServiceReportDistr] PRIMARY KEY CLUSTERED ([SRD_ID]),
        CONSTRAINT [FK_dbo.ServiceReportDistr(SRD_ID_SR)_dbo.ServiceReport(SR_ID)] FOREIGN KEY  ([SRD_ID_SR]) REFERENCES [dbo].[ServiceReport] ([SR_ID])
);GO
