USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IncomeTypeTable]
(
        [IT_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [IT_NAME]     VarChar(50)                   NOT NULL,
        [IT_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.IncomeTypeTable] PRIMARY KEY CLUSTERED ([IT_ID])
);GO
