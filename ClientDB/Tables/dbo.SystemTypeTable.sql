USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTypeTable]
(
        [SystemTypeID]     Int           Identity(1,1)   NOT NULL,
        [SystemTypeName]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.SystemTypeTable] PRIMARY KEY CLUSTERED ([SystemTypeID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.SystemTypeTable(SystemTypeName)] ON [dbo].[SystemTypeTable] ([SystemTypeName] ASC);
GO
GRANT SELECT ON [dbo].[SystemTypeTable] TO claim_view;
GO
