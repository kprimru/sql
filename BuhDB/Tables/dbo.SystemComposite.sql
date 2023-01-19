USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemComposite]
(
        [ID]             Int   Identity(1,1)   NOT NULL,
        [ID_SYSTEM]      Int                   NOT NULL,
        [ID_COMPOSITE]   Int                   NOT NULL,
        CONSTRAINT [PK_dbo.SystemComposite] PRIMARY KEY CLUSTERED ([ID])
);
GO
