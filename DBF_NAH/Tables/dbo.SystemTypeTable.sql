USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTypeTable]
(
        [SST_ID]         SmallInt      Identity(1,1)   NOT NULL,
        [SST_NAME]       VarChar(20)                   NOT NULL,
        [SST_CAPTION]    VarChar(50)                   NOT NULL,
        [SST_LST]        VarChar(20)                   NOT NULL,
        [SST_REPORT]     Bit                           NOT NULL,
        [SST_ACTIVE]     Bit                           NOT NULL,
        [SST_ORDER]      SmallInt                          NULL,
        [SST_ID_MOS]     SmallInt                          NULL,
        [SST_ID_SUB]     SmallInt                          NULL,
        [SST_ID_HOST]    SmallInt                          NULL,
        [SST_ID_DHOST]   SmallInt                          NULL,
        [SST_COEF]       Bit                               NULL,
        [SST_SORDER]     Int                               NULL,
        [SST_PORDER]     Int                               NULL,
        [SST_CALC]       decimal                           NULL,
        [SST_KBU]        Bit                               NULL,
        CONSTRAINT [PK_dbo.SystemTypeTable] PRIMARY KEY CLUSTERED ([SST_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_U_SST_CAPTION] ON [dbo].[SystemTypeTable] ([SST_CAPTION] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [IX_U_SST_LST] ON [dbo].[SystemTypeTable] ([SST_LST] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.SystemTypeTable()] ON [dbo].[SystemTypeTable] ([SST_NAME] ASC);
GO
