USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceDepend]
(
        [PD_ID]          Int        Identity(1,1)   NOT NULL,
        [PD_ID_TYPE]     SmallInt                   NOT NULL,
        [PD_ID_SOURCE]   SmallInt                   NOT NULL,
        [PD_ID_PERIOD]   SmallInt                   NOT NULL,
        [PD_COEF]        decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.PriceDepend] PRIMARY KEY CLUSTERED ([PD_ID]),
        CONSTRAINT [FK_dbo.PriceDepend(PD_ID_SOURCE)_dbo.PriceTypeTable(PT_ID)] FOREIGN KEY  ([PD_ID_SOURCE]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID]),
        CONSTRAINT [FK_dbo.PriceDepend(PD_ID_TYPE)_dbo.PriceTypeTable(PT_ID)] FOREIGN KEY  ([PD_ID_TYPE]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID]),
        CONSTRAINT [FK_dbo.PriceDepend(PD_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([PD_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.PriceDepend(PD_ID_TYPE,PD_ID_PERIOD)] ON [dbo].[PriceDepend] ([PD_ID_TYPE] ASC, [PD_ID_PERIOD] ASC);
GO
