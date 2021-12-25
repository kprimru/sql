USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Act1C]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [ID_ORG]      SmallInt              NOT NULL,
        [START]       SmallDateTime         NOT NULL,
        [FINISH]      SmallDateTime         NOT NULL,
        [ID_SYSTEM]   SmallInt              NOT NULL,
        [DATE]        DateTime              NOT NULL,
        [TOTAL]       Bit                       NULL,
        [USR_NAME]    NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.Act1C] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.Act1C(ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID]),
        CONSTRAINT [FK_dbo.Act1C(ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);GO
