USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ComplianceTypeTable]
(
        [ComplianceTypeID]          TinyInt       Identity(1,1)   NOT NULL,
        [ComplianceTypeName]        VarChar(50)                   NOT NULL,
        [ComplianceTypeShortName]   VarChar(50)                   NOT NULL,
        [ComplianceTypeOrder]       Int                           NOT NULL,
        CONSTRAINT [PK_dbo.ComplianceTypeTable] PRIMARY KEY CLUSTERED ([ComplianceTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.ComplianceTypeTable(ComplianceTypeName)] ON [dbo].[ComplianceTypeTable] ([ComplianceTypeName] ASC);
GO
