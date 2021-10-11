USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__TechnolTypePeriod]
(
        [TTP_ID]          Int        Identity(1,1)   NOT NULL,
        [TTP_ID_TECH]     SmallInt                   NOT NULL,
        [TTP_ID_PERIOD]   SmallInt                   NOT NULL,
        [TTP_COEF]        decimal                    NOT NULL,
        [TTP_CALC]        decimal                        NULL,
        CONSTRAINT [PK_dbo.__TechnolTypePeriod] PRIMARY KEY CLUSTERED ([TTP_ID]),
        CONSTRAINT [FK_dbo.__TechnolTypePeriod(TTP_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([TTP_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.__TechnolTypePeriod(TTP_ID_TECH)_dbo.TechnolTypeTable(TT_ID)] FOREIGN KEY  ([TTP_ID_TECH]) REFERENCES [dbo].[TechnolTypeTable] ([TT_ID])
);GO
