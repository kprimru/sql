USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActionType]
(
        [ACTT_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [ACTT_NAME]     VarChar(50)                   NOT NULL,
        [ACTT_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.ActionType] PRIMARY KEY CLUSTERED ([ACTT_ID])
);GO
