USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AreaTable]
(
        [AR_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [AR_NAME]     VarChar(150)                   NOT NULL,
        [AR_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.AreaTable] PRIMARY KEY CLUSTERED ([AR_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.AreaTable()] ON [dbo].[AreaTable] ([AR_NAME] ASC);
GO
