USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegionTable]
(
        [RG_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [RG_NAME]       VarChar(150)                   NOT NULL,
        [RG_OLD_CODE]   Int                                NULL,
        [RG_ACTIVE]     Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.RegionTable] PRIMARY KEY CLUSTERED ([RG_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.RegionTable()] ON [dbo].[RegionTable] ([RG_NAME] ASC);
GO
