USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Proverka]
(
        [SYS]       NVarChar(510)          NULL,
        [SUB]       Int                    NULL,
        [DISTR]     Int                    NULL,
        [COMP]      TinyInt                NULL,
        [TO_NUM]    Int                    NULL,
        [TO_NAME]   NVarChar(510)          NULL,
        [MANAGER]   NVarChar(510)          NULL,
        [DEC_13]    NVarChar(510)          NULL,
        [MAR_14]    NVarChar(510)          NULL,
        [SEP_14]    NVarChar(510)          NULL,
        [DEC_14]    NVarChar(510)          NULL,
        [MAR_15]    NVarChar(510)          NULL,
        [JUN_15]    NVarChar(510)          NULL,
        [SEP_15]    NVarChar(510)          NULL,
        [MAR_16]    NVarChar(510)          NULL,
);GO
