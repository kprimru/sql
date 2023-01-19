USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Provision]
(
        [ID]          Int             Identity(1,1)   NOT NULL,
        [ID_CLIENT]   Int                             NOT NULL,
        [DATE]        SmallDateTime                   NOT NULL,
        [PRICE]       Money                           NOT NULL,
        [PAY_NUM]     Int                                 NULL,
        [ID_ORG]      SmallInt                            NULL,
        CONSTRAINT [PK_dbo.Provision] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.Provision(ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID]),
        CONSTRAINT [FK_dbo.Provision(ID_ORG)_dbo.OrganizationTable(ORG_ID)] FOREIGN KEY  ([ID_ORG]) REFERENCES [dbo].[OrganizationTable] ([ORG_ID])
);
GO
