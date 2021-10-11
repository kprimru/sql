USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtproperties]
(
        [id]         Int             Identity(1,1)   NOT NULL,
        [objectid]   Int                                 NULL,
        [property]   VarChar(64)                     NOT NULL,
        [value]      VarChar(255)                        NULL,
        [uvalue]     NVarChar(510)                       NULL,
        [lvalue]     image                               NULL,
        [version]    Int                             NOT NULL,
        CONSTRAINT [pk_dtproperties] PRIMARY KEY CLUSTERED ([id],[property])
);GO
