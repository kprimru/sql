USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[DistrTypeDetail]
(
        [DT_ID]          UniqueIdentifier      NOT NULL,
        [DT_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [DT_NAME]        VarChar(50)           NOT NULL,
        [DT_SHORT]       VarChar(50)               NULL,
        [DT_REG]         VarChar(50)           NOT NULL,
        [DT_DATE]        SmallDateTime         NOT NULL,
        [DT_END]         SmallDateTime             NULL,
        [DT_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_DistrType] PRIMARY KEY CLUSTERED ([DT_ID]),
        CONSTRAINT [FK_DistrType_DistrType] FOREIGN KEY  ([DT_ID_MASTER]) REFERENCES [Distr].[DistrType] ([DTMS_ID])
);GO
