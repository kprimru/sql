USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[NetTypeDetail]
(
        [NT_ID]          UniqueIdentifier      NOT NULL,
        [NT_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [NT_NAME]        VarChar(50)           NOT NULL,
        [NT_SHORT]       VarChar(50)               NULL,
        [NT_FULL]        VarChar(50)           NOT NULL,
        [NT_COEF]        decimal               NOT NULL,
        [NT_DATE]        SmallDateTime         NOT NULL,
        [NT_END]         SmallDateTime             NULL,
        [NT_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Distr.NetTypeDetail] PRIMARY KEY CLUSTERED ([NT_ID])
);
GO
