USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentTable]
(
        [DOC_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [DOC_NAME]     VarChar(50)                   NOT NULL,
        [DOC_PSEDO]    VarChar(50)                       NULL,
        [DOC_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.DocumentTable] PRIMARY KEY CLUSTERED ([DOC_ID])
);
GO
