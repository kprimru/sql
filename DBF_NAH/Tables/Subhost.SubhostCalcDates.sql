USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostCalcDates]
(
        [SCD_ID]          SmallInt        Identity(1,1)   NOT NULL,
        [SCD_ID_PERIOD]   SmallInt                        NOT NULL,
        [SCD_DATE]        SmallDateTime                   NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostCalcDates] PRIMARY KEY CLUSTERED ([SCD_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalcDates(SCD_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SCD_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
