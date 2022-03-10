USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrStatusTable]
(
        [DS_ID]       SmallInt      Identity(1,1)   NOT NULL,
        [DS_NAME]     VarChar(50)                   NOT NULL,
        [DS_REG]      TinyInt                       NOT NULL,
        [DS_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.DistrStatusTable] PRIMARY KEY CLUSTERED ([DS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.DistrStatusTable(DS_NAME)] ON [dbo].[DistrStatusTable] ([DS_NAME] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.DistrStatusTable(DS_REG)] ON [dbo].[DistrStatusTable] ([DS_REG] ASC);
GO
