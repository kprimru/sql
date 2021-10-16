USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PurposesForbiddenWords]
(
        [Id]         SmallInt       Identity(1,1)   NOT NULL,
        [Mask]       VarChar(256)                   NOT NULL,
        [IsActive]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.PurposeForbiddenWords] PRIMARY KEY CLUSTERED ([Id])
);GO
