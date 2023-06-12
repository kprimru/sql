USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PeriodTable]
(
        [PR_ID]         SmallInt        Identity(1,1)   NOT NULL,
        [PR_NAME]       VarChar(50)                     NOT NULL,
        [PR_DATE]       SmallDateTime                   NOT NULL,
        [PR_END_DATE]   SmallDateTime                   NOT NULL,
        [PR_BREPORT]    SmallDateTime                       NULL,
        [PR_EREPORT]    SmallDateTime                       NULL,
        [PR_ACTIVE]     Bit                             NOT NULL,
        CONSTRAINT [PK_dbo.PeriodTable] PRIMARY KEY CLUSTERED ([PR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.PeriodTable(PR_DATE)] ON [dbo].[PeriodTable] ([PR_DATE] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.PeriodTable(PR_NAME)] ON [dbo].[PeriodTable] ([PR_NAME] ASC);
GO
GRANT SELECT ON [dbo].[PeriodTable] TO rl_fin_r;
GRANT SELECT ON [dbo].[PeriodTable] TO rl_reg_node_report_r;
GO
