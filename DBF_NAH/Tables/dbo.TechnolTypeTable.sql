﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TechnolTypeTable]
(
        [TT_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [TT_NAME]     VarChar(150)                   NOT NULL,
        [TT_REG]      SmallInt                       NOT NULL,
        [TT_COEF]     decimal                        NOT NULL,
        [TT_USR]      VarChar(50)                        NULL,
        [TT_ACTIVE]   Bit                            NOT NULL,
        [TT_CALC]     decimal                            NULL,
        CONSTRAINT [PK_dbo.TechnolTypeTable] PRIMARY KEY CLUSTERED ([TT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.TechnolTypeTable(TT_NAME)] ON [dbo].[TechnolTypeTable] ([TT_NAME] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.TechnolTypeTable(TT_REG)] ON [dbo].[TechnolTypeTable] ([TT_REG] ASC);
GO
