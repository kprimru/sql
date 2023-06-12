USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostPriceSystemTable]
(
        [SPS_ID]          Int        Identity(1,1)   NOT NULL,
        [SPS_ID_PERIOD]   SmallInt                   NOT NULL,
        [SPS_ID_HOST]     SmallInt                   NOT NULL,
        [SPS_ID_SYSTEM]   SmallInt                   NOT NULL,
        [SPS_ID_TYPE]     SmallInt                   NOT NULL,
        [SPS_PRICE]       Money                      NOT NULL,
        [SPS_ACTIVE]      Bit                        NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostPriceSystemTable] PRIMARY KEY CLUSTERED ([SPS_ID]),
        CONSTRAINT [FK_Subhost.SubhostPriceSystemTable(SPS_ID_TYPE)_Subhost.PriceTypeTable(PT_ID)] FOREIGN KEY  ([SPS_ID_TYPE]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID]),
        CONSTRAINT [FK_Subhost.SubhostPriceSystemTable(SPS_ID_HOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SPS_ID_HOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostPriceSystemTable(SPS_ID_SYSTEM)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([SPS_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_Subhost.SubhostPriceSystemTable(SPS_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SPS_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostPriceSystemTable(SPS_ID_PERIOD,SPS_ID_SYSTEM,SPS_ID_TYPE,SPS_ID_HOST)+(SPS_PRICE)] ON [Subhost].[SubhostPriceSystemTable] ([SPS_ID_PERIOD] ASC, [SPS_ID_SYSTEM] ASC, [SPS_ID_TYPE] ASC, [SPS_ID_HOST] ASC) INCLUDE ([SPS_PRICE]);
GO
