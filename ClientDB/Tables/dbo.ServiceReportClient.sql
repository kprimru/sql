USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceReportClient]
(
        [SRC_ID]           UniqueIdentifier      NOT NULL,
        [SRC_ID_SR]        UniqueIdentifier      NOT NULL,
        [SRC_ID_CLIENT]    Int                   NOT NULL,
        [SRC_NAME]         VarChar(250)          NOT NULL,
        [SCR_CO_COND]      VarChar(250)              NULL,
        [SRC_CO_TYPE]      VarChar(100)              NULL,
        [SRC_PAY_TYPE]     VarChar(100)              NULL,
        [SRC_CLIENT_PAY]   VarChar(100)              NULL,
        [SRC_PAPPER]       Int                       NULL,
        [SRC_BOOK]         Int                       NULL,
        [SRC_NET]          VarChar(20)               NULL,
        [SRC_STATUS]       VarChar(50)               NULL,
        CONSTRAINT [PK_dbo.ServiceReportClient] PRIMARY KEY CLUSTERED ([SRC_ID]),
        CONSTRAINT [FK_dbo.ServiceReportClient(SRC_ID_SR)_dbo.ServiceReport(SR_ID)] FOREIGN KEY  ([SRC_ID_SR]) REFERENCES [dbo].[ServiceReport] ([SR_ID])
);GO
