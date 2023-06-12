USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTypeVKSP]
(
        [SSTV_ID]          Int        Identity(1,1)   NOT NULL,
        [SSTV_ID_SST]      SmallInt                   NOT NULL,
        [SSTV_ID_PERIOD]   SmallInt                   NOT NULL,
        CONSTRAINT [PK_dbo.SystemTypeVKSP] PRIMARY KEY CLUSTERED ([SSTV_ID]),
        CONSTRAINT [FK_dbo.SystemTypeVKSP(SSTV_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([SSTV_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.SystemTypeVKSP(SSTV_ID_SST)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([SSTV_ID_SST]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemTypeVKSP(SSTV_ID_PERIOD,SSTV_ID_SST)] ON [dbo].[SystemTypeVKSP] ([SSTV_ID_PERIOD] ASC, [SSTV_ID_SST] ASC);
GO
