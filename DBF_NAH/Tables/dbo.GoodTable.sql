USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoodTable]
(
        [GD_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [GD_NAME]     VarChar(150)                   NOT NULL,
        [GD_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.GoodTable] PRIMARY KEY CLUSTERED ([GD_ID])
);GO
