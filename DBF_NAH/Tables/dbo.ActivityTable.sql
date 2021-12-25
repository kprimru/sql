USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityTable]
(
        [AC_ID]         SmallInt      Identity(1,1)   NOT NULL,
        [AC_NAME]       VarChar(50)                   NOT NULL,
        [AC_ACTIVE]     Bit                           NOT NULL,
        [AC_OLD_CODE]   Int                               NULL,
        CONSTRAINT [PK_dbo.ActivityTable] PRIMARY KEY CLUSTERED ([AC_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ActivityTable()] ON [dbo].[ActivityTable] ([AC_NAME] ASC);
GO
