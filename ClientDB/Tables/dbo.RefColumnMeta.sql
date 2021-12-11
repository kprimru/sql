USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RefColumnMeta]
(
        [MetaId]        Int             Identity(1,1)   NOT NULL,
        [RefName]       NVarChar(256)                   NOT NULL,
        [IdColumn]      NVarChar(256)                   NOT NULL,
        [ValueColumn]   NVarChar(256)                   NOT NULL,
        CONSTRAINT [PK_dbo.RefColumnMeta] PRIMARY KEY CLUSTERED ([MetaId])
);
GO
