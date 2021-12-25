USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractPayTable]
(
        [COP_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [COP_NAME]     VarChar(50)                   NOT NULL,
        [COP_DAY]      TinyInt                           NULL,
        [COP_MONTH]    TinyInt                           NULL,
        [COP_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.ContractPayTable] PRIMARY KEY CLUSTERED ([COP_ID])
);GO
