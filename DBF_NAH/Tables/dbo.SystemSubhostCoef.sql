USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemSubhostCoef]
(
        [SSC_ID]          Int        Identity(1,1)   NOT NULL,
        [SSC_ID_SYSTEM]   SmallInt                   NOT NULL,
        [SSC_ID_PERIOD]   SmallInt                   NOT NULL,
        [SSC_COEF]        decimal                    NOT NULL,
        CONSTRAINT [PK_dbo.SystemSubhostCoef] PRIMARY KEY CLUSTERED ([SSC_ID]),
        CONSTRAINT [FK_dbo.SystemSubhostCoef(SSC_ID_PERIOD)_dbo.PeriodTable(PR_ID)] FOREIGN KEY  ([SSC_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID]),
        CONSTRAINT [FK_dbo.SystemSubhostCoef(SSC_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([SSC_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);GO
