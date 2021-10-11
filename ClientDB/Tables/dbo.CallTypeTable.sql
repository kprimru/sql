USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CallTypeTable]
(
        [CallTypeID]      Int           Identity(1,1)   NOT NULL,
        [CallTypeName]    VarChar(50)                   NOT NULL,
        [CallTypeShort]   VarChar(50)                       NULL,
        CONSTRAINT [PK_dbo.CallTypeTable] PRIMARY KEY CLUSTERED ([CallTypeID])
);GO
