USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Install].[InstallActDetail]
(
        [IA_ID]          UniqueIdentifier      NOT NULL,
        [IA_ID_MASTER]   UniqueIdentifier          NULL,
        [IA_NAME]        VarChar(50)           NOT NULL,
        [IA_NORM]        Bit                   NOT NULL,
        [IA_DATE]        SmallDateTime         NOT NULL,
        [IA_END]         SmallDateTime             NULL,
        [IA_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_InstallActDetail] PRIMARY KEY CLUSTERED ([IA_ID])
);GO
