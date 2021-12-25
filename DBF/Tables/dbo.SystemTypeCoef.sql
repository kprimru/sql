USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTypeCoef]
(
        [STC_ID]          Int        Identity(1,1)   NOT NULL,
        [STC_ID_TYPE]     SmallInt                   NOT NULL,
        [STC_ID_PERIOD]   SmallInt                   NOT NULL,
        [STC_VALUE]       decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.SystemTypeCoef] PRIMARY KEY CLUSTERED ([STC_ID]),
        CONSTRAINT [FK_dbo.SystemTypeCoef(STC_ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([STC_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID]),
        CONSTRAINT [FK_dbo.SystemTypeCoef(STC_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([STC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
