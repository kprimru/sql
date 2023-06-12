USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Reference]
(
        [ReferenceId]       Int            Identity(1,1)   NOT NULL,
        [ReferenceSchema]   VarChar(100)                   NOT NULL,
        [ReferenceName]     VarChar(100)                   NOT NULL,
        [ReferenceLast]     DateTime                           NULL,
        CONSTRAINT [PK_Common.Reference] PRIMARY KEY NONCLUSTERED ([ReferenceId])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Common.Reference(ReferenceSchema,ReferenceName)] ON [Common].[Reference] ([ReferenceSchema] ASC, [ReferenceName] ASC);
GO
