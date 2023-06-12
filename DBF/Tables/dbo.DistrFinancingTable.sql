USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrFinancingTable]
(
        [DF_ID]             Int             Identity(1,1)   NOT NULL,
        [DF_ID_DISTR]       Int                             NOT NULL,
        [DF_ID_NET]         SmallInt                        NOT NULL,
        [DF_ID_TECH_TYPE]   SmallInt                            NULL,
        [DF_ID_TYPE]        SmallInt                            NULL,
        [DF_ID_SCHEMA]      SmallInt                            NULL,
        [DF_ID_PRICE]       SmallInt                        NOT NULL,
        [DF_DISCOUNT]       decimal                         NOT NULL,
        [DF_COEF]           decimal                         NOT NULL,
        [DF_FIXED_PRICE]    Money                           NOT NULL,
        [DF_ID_PERIOD]      SmallInt                            NULL,
        [DF_MON_COUNT]      TinyInt                             NULL,
        [DF_ID_PAY]         SmallInt                            NULL,
        [DF_DEBT]           Bit                                 NULL,
        [DF_END]            SmallDateTime                       NULL,
        [DF_BEGIN]          SmallDateTime                       NULL,
        [DF_NAME]           NVarChar(512)                       NULL,
        [DF_EXPIRE]         SmallDateTime                       NULL,
        CONSTRAINT [PK_dbo.DistrFinancingTable] PRIMARY KEY NONCLUSTERED ([DF_ID]),
        CONSTRAINT [FK_dbo.DistrFinancingTable(DF_ID_NET)_dbo.SystemNetTable(SN_ID)] FOREIGN KEY  ([DF_ID_NET]) REFERENCES [dbo].[SystemNetTable] ([SN_ID]),
        CONSTRAINT [FK_dbo.DistrFinancingTable(DF_ID_PRICE)_dbo.PriceTable(PP_ID)] FOREIGN KEY  ([DF_ID_PRICE]) REFERENCES [dbo].[PriceTable] ([PP_ID]),
        CONSTRAINT [FK_dbo.DistrFinancingTable(DF_ID_DISTR)_dbo.DistrTable(DIS_ID)] FOREIGN KEY  ([DF_ID_DISTR]) REFERENCES [dbo].[DistrTable] ([DIS_ID]),
        CONSTRAINT [FK_dbo.DistrFinancingTable(DF_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([DF_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.DistrFinancingTable(DF_ID_TECH_TYPE)_dbo.TechnolTypeTable(TT_ID)] FOREIGN KEY  ([DF_ID_TECH_TYPE]) REFERENCES [dbo].[TechnolTypeTable] ([TT_ID]),
        CONSTRAINT [FK_dbo.DistrFinancingTable(DF_ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([DF_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.DistrFinancingTable(DF_ID_DISTR)] ON [dbo].[DistrFinancingTable] ([DF_ID_DISTR] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrFinancingTable(DF_END)+INCL] ON [dbo].[DistrFinancingTable] ([DF_END] ASC) INCLUDE ([DF_ID_DISTR], [DF_ID_NET], [DF_ID_TECH_TYPE], [DF_ID_TYPE], [DF_ID_PRICE], [DF_DISCOUNT], [DF_FIXED_PRICE], [DF_ID_PERIOD]);
CREATE NONCLUSTERED INDEX [IX_dbo.DistrFinancingTable(DF_ID_DISTR)+INCL] ON [dbo].[DistrFinancingTable] ([DF_ID_DISTR] ASC) INCLUDE ([DF_ID_NET], [DF_ID_TECH_TYPE], [DF_ID_TYPE], [DF_ID_PRICE], [DF_DISCOUNT], [DF_COEF], [DF_FIXED_PRICE], [DF_ID_PERIOD], [DF_MON_COUNT]);
GO
