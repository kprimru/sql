USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemNetCoef]
(
        [SNCC_ID]          Int        Identity(1,1)   NOT NULL,
        [SNCC_ID_SN]       SmallInt                   NOT NULL,
        [SNCC_ID_PERIOD]   SmallInt                   NOT NULL,
        [SNCC_VALUE]       decimal                    NOT NULL,
        [SNCC_WEIGHT]      decimal                    NOT NULL,
        [SNCC_SUBHOST]     decimal                        NULL,
        [SNCC_ROUND]       SmallInt                   NOT NULL,
        [SNCC_ACTIVE]      Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.SystemNetCoef] PRIMARY KEY CLUSTERED ([SNCC_ID]),
        CONSTRAINT [FK_dbo.SystemNetCoef(SNCC_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([SNCC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.SystemNetCoef(SNCC_ID_SN)_dbo.SystemNetTable(SN_ID)] FOREIGN KEY  ([SNCC_ID_SN]) REFERENCES [dbo].[SystemNetTable] ([SN_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemNetCoef(SNCC_ID_PERIOD,SNCC_ID_SN)+(SNCC_VALUE,SNCC_WEIGHT,SNCC_ROUND)] ON [dbo].[SystemNetCoef] ([SNCC_ID_PERIOD] ASC, [SNCC_ID_SN] ASC) INCLUDE ([SNCC_VALUE], [SNCC_WEIGHT], [SNCC_ROUND]);
GO
