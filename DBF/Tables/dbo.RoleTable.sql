USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleTable]
(
        [ROLE_ID]     SmallInt       Identity(1,1)   NOT NULL,
        [ROLE_NAME]   VarChar(50)                    NOT NULL,
        [ROLE_NOTE]   VarChar(500)                   NOT NULL,
        CONSTRAINT [PK_dbo.RoleTable] PRIMARY KEY CLUSTERED ([ROLE_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.RoleTable(ROLE_NAME)] ON [dbo].[RoleTable] ([ROLE_NAME] ASC);
GO
