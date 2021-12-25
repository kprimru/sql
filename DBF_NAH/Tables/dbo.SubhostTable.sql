USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostTable]
(
        [SH_ID]            SmallInt       Identity(1,1)   NOT NULL,
        [SH_FULL_NAME]     VarChar(250)                       NULL,
        [SH_SHORT_NAME]    VarChar(50)                        NULL,
        [SH_SUBHOST]       Bit                                NULL,
        [SH_LST_NAME]      VarChar(50)                    NOT NULL,
        [SH_REG]           Bit                                NULL,
        [SH_CALC_STUDY]    Bit                                NULL,
        [SH_CALC_SYSTEM]   Bit                                NULL,
        [SH_ACTIVE]        Bit                            NOT NULL,
        [SH_ORDER]         SmallInt                       NOT NULL,
        [SH_CALC]          decimal                            NULL,
        [SH_PENALTY]       decimal                            NULL,
        [SH_PERIODICITY]   SmallInt                           NULL,
        CONSTRAINT [PK_dbo.SubhostTable] PRIMARY KEY NONCLUSTERED ([SH_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.SubhostTable()] ON [dbo].[SubhostTable] ([SH_SHORT_NAME] ASC);
GO
