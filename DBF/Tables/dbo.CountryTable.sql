USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CountryTable]
(
        [CNT_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [CNT_NAME]       VarChar(150)                   NOT NULL,
        [CNT_ACTIVE]     Bit                            NOT NULL,
        [CNT_OLD_CODE]   Int                                NULL,
        CONSTRAINT [PK_dbo.CountryTable] PRIMARY KEY CLUSTERED ([CNT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.CountryTable()] ON [dbo].[CountryTable] ([CNT_NAME] ASC);
GO
