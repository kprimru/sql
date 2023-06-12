USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostPay]
(
        [SHP_ID]           Int             Identity(1,1)   NOT NULL,
        [SHP_ID_SUBHOST]   SmallInt                        NOT NULL,
        [SHP_ID_PERIOD]    SmallInt                            NULL,
        [SHP_ID_ORG]       SmallInt                        NOT NULL,
        [SHP_DATE]         SmallDateTime                   NOT NULL,
        [SHP_SUM]          Money                           NOT NULL,
        [SHP_COMMENT]      VarChar(200)                    NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostPay] PRIMARY KEY CLUSTERED ([SHP_ID]),
        CONSTRAINT [FK_Subhost.SubhostPay(SHP_ID_ORG)_Subhost.OrganizationTable(ORG_ID)] FOREIGN KEY  ([SHP_ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_Subhost.SubhostPay(SHP_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([SHP_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID]),
        CONSTRAINT [FK_Subhost.SubhostPay(SHP_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SHP_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);
GO
