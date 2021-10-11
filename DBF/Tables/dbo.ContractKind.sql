USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractKind]
(
        [CK_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [CK_NAME]     VarChar(50)                   NOT NULL,
        [CK_HEADER]   VarChar(50)                   NOT NULL,
        [CK_CENTER]   VarChar(50)                   NOT NULL,
        [CK_FOOTER]   VarChar(50)                   NOT NULL,
        [CK_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.ContractKind] PRIMARY KEY CLUSTERED ([CK_ID])
);GO
