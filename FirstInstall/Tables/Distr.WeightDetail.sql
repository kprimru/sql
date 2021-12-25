USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[WeightDetail]
(
        [WG_ID]          UniqueIdentifier      NOT NULL,
        [WG_ID_MASTER]   UniqueIdentifier          NULL,
        [WG_NAME]        VarChar(50)           NOT NULL,
        [WG_ID_SYSTEM]   UniqueIdentifier      NOT NULL,
        [WG_VALUE]       decimal               NOT NULL,
        [WG_DATE]        SmallDateTime         NOT NULL,
        [WG_END]         SmallDateTime             NULL,
        [WG_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Weight] PRIMARY KEY CLUSTERED ([WG_ID]),
        CONSTRAINT [FK_Weight_Systems] FOREIGN KEY  ([WG_ID_SYSTEM]) REFERENCES [Distr].[Systems] ([SYSMS_ID]),
        CONSTRAINT [FK_Weight_Weight] FOREIGN KEY  ([WG_ID_MASTER]) REFERENCES [Distr].[Weight] ([WGMS_ID])
);GO
