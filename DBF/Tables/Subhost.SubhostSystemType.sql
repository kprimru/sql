USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostSystemType]
(
        [SSST_ID]           Int           Identity(1,1)   NOT NULL,
        [SSST_ID_SUBHOST]   SmallInt                      NOT NULL,
        [SSST_ID_PERIOD]    SmallInt                      NOT NULL,
        [SSST_TYPE]         VarChar(20)                   NOT NULL,
        [SST_ID]            SmallInt                      NOT NULL,
        [SST_CAPTION]       VarChar(50)                   NOT NULL,
        [SST_COEF]          Bit                           NOT NULL,
        [SST_KBU]           Bit                           NOT NULL,
        [SST_ORDER]         Int                           NOT NULL,
        [SST_COUNT]         SmallInt                      NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostSystemType] PRIMARY KEY CLUSTERED ([SSST_ID])
);
GO
