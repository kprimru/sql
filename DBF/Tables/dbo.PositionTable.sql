USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PositionTable]
(
        [POS_ID]           SmallInt       Identity(1,1)   NOT NULL,
        [POS_NAME]         VarChar(150)                       NULL,
        [POS_SHORT_NAME]   VarChar(50)                        NULL,
        [POS_ACTIVE]       Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.PositionTable] PRIMARY KEY CLUSTERED ([POS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.PositionTable(POS_NAME)] ON [dbo].[PositionTable] ([POS_NAME] ASC);
GO
