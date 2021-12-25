USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Numbers]
(
        [ID]   bigint      NOT NULL,
        CONSTRAINT [PK_dbo.Numbers] PRIMARY KEY CLUSTERED ([ID])
);GO
GRANT SELECT ON [dbo].[Numbers] TO public;
GO
