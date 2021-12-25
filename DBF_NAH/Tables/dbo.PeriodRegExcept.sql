USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PeriodRegExcept]
(
        [PRE_ID]          Int        Identity(1,1)   NOT NULL,
        [PRE_ID_PERIOD]   SmallInt                   NOT NULL,
        [PRE_ID_SYSTEM]   SmallInt                   NOT NULL,
        [PRE_DISTR]       Int                        NOT NULL,
        [PRE_COMP]        Int                        NOT NULL,
        [PRE_ID_HOST]     SmallInt                   NOT NULL,
        [PRE_ID_TYPE]     SmallInt                   NOT NULL,
        [PRE_ID_NET]      SmallInt                   NOT NULL,
        [PRE_ID_STATUS]   SmallInt                   NOT NULL,
        [PRE_ID_TECH]     SmallInt                       NULL,
        CONSTRAINT [PK_dbo.PeriodRegExcept] PRIMARY KEY CLUSTERED ([PRE_ID])
);GO
