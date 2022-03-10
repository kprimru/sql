USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[SystemDetail]
(
        [SYS_ID]          UniqueIdentifier      NOT NULL,
        [SYS_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [SYS_ID_HOST]     UniqueIdentifier          NULL,
        [SYS_NAME]        VarChar(50)           NOT NULL,
        [SYS_SHORT]       VarChar(50)               NULL,
        [SYS_REG]         VarChar(50)               NULL,
        [SYS_WEIGHT]      Int                       NULL,
        [SYS_ORDER]       Int                       NULL,
        [SYS_DATE]        SmallDateTime         NOT NULL,
        [SYS_END]         SmallDateTime             NULL,
        [SYS_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Distr.SystemDetail] PRIMARY KEY CLUSTERED ([SYS_ID]),
        CONSTRAINT [FK_Distr.SystemDetail(SYS_ID_HOST)_Distr.Hosts(HSTMS_ID)] FOREIGN KEY  ([SYS_ID_HOST]) REFERENCES [Distr].[Hosts] ([HSTMS_ID]),
        CONSTRAINT [FK_Distr.SystemDetail(SYS_ID_MASTER)_Distr.Systems(SYSMS_ID)] FOREIGN KEY  ([SYS_ID_MASTER]) REFERENCES [Distr].[Systems] ([SYSMS_ID])
);GO
