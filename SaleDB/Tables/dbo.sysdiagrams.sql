USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysdiagrams]
(
        [name]           sysname                     NOT NULL,
        [principal_id]   Int                         NOT NULL,
        [diagram_id]     Int         Identity(1,1)   NOT NULL,
        [version]        Int                             NULL,
        [definition]     varbinary                       NULL,
        CONSTRAINT [PK__sysdiagrams__379037E3] PRIMARY KEY CLUSTERED ([diagram_id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_principal_name] ON [dbo].[sysdiagrams] ([principal_id] ASC, [name] ASC);
GO
