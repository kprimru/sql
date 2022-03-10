USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[HostDetail]
(
        [HST_ID]          UniqueIdentifier      NOT NULL,
        [HST_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [HST_NAME]        VarChar(250)          NOT NULL,
        [HST_REG]         VarChar(50)           NOT NULL,
        [HST_DATE]        SmallDateTime         NOT NULL,
        [HST_END]         SmallDateTime             NULL,
        [HST_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Distr.HostDetail] PRIMARY KEY CLUSTERED ([HST_ID]),
        CONSTRAINT [FK_Distr.HostDetail(HST_ID_MASTER)_Distr.Hosts(HSTMS_ID)] FOREIGN KEY  ([HST_ID_MASTER]) REFERENCES [Distr].[Hosts] ([HSTMS_ID])
);GO
