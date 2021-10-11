USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Ric].[RiseCoef]
(
        [RC_ID]          Int        Identity(1,1)   NOT NULL,
        [RC_ID_PERIOD]   SmallInt                   NOT NULL,
        [RC_VALUE]       decimal                    NOT NULL,
        CONSTRAINT [PK_Ric.RiseCoef] PRIMARY KEY CLUSTERED ([RC_ID]),
        CONSTRAINT [FK_Ric.RiseCoef(RC_ID_PERIOD)_Ric.PeriodTable(PR_ID)] FOREIGN KEY  ([RC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
