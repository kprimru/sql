USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostCalcSettings]
(
        [SCS_ID]               Int        Identity(1,1)   NOT NULL,
        [SCS_ID_ORG_STUDY]     SmallInt                   NOT NULL,
        [SCS_ID_ORG_SERVICE]   SmallInt                   NOT NULL,
        [SCS_ACTIVE]           Bit                        NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostCalcSettings] PRIMARY KEY CLUSTERED ([SCS_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalcSettings(SCS_ID_ORG_SERVICE)_Subhost.OrganizationTable(ORG_ID)] FOREIGN KEY  ([SCS_ID_ORG_SERVICE]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_Subhost.SubhostCalcSettings(SCS_ID_ORG_STUDY)_Subhost.OrganizationTable(ORG_ID)] FOREIGN KEY  ([SCS_ID_ORG_STUDY]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID])
);GO
