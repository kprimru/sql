USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnitTable]
(
        [UN_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [UN_NAME]     VarChar(100)                   NOT NULL,
        [UN_OKEI]     VarChar(50)                    NOT NULL,
        [UN_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.UnitTable] PRIMARY KEY CLUSTERED ([UN_ID])
);GO
