USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NetTypeCoef]
(
        [NTC_ID]          Int        Identity(1,1)   NOT NULL,
        [NTC_ID_PERIOD]   SmallInt                   NOT NULL,
        [NTC_ID_NET]      SmallInt                   NOT NULL,
        [NTC_WEIGHT]      decimal                    NOT NULL,
        [NTC_COEF]        decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.NetTypeCoef] PRIMARY KEY CLUSTERED ([NTC_ID]),
        CONSTRAINT [FK_dbo.NetTypeCoef(NTC_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([NTC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.NetTypeCoef(NTC_ID_NET)_dbo.NetType(NT_ID)] FOREIGN KEY  ([NTC_ID_NET]) REFERENCES [dbo].[NetType] ([NT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.NetTypeCoef(NTC_ID_PERIOD,NTC_ID_NET)] ON [dbo].[NetTypeCoef] ([NTC_ID_PERIOD] ASC, [NTC_ID_NET] ASC);
GO
