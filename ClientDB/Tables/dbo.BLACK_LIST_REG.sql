USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BLACK_LIST_REG]
(
        [ID]               Int            Identity(1,1)   NOT NULL,
        [ID_SYS]           Int                            NOT NULL,
        [DISTR]            Int                            NOT NULL,
        [COMP]             SmallInt                       NOT NULL,
        [DATE]             DateTime                       NOT NULL,
        [COMMENT]          VarChar(300)                       NULL,
        [U_LOGIN]          VarChar(128)                   NOT NULL,
        [DATE_DELETE]      DateTime                           NULL,
        [U_LOGIN_DELETE]   VarChar(128)                       NULL,
        [P_DELETE]         Int                            NOT NULL,
        [COMMENT_DELETE]   VarChar(300)                       NULL,
        [COMPLECTNAME]     VarChar(20)                        NULL,,
        CONSTRAINT [FK_dbo.BLACK_LIST_REG(ID_SYS)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([ID_SYS]) REFERENCES [dbo].[SystemTable] ([SystemID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.BLACK_LIST_REG(DISTR,ID_SYS,COMP,P_DELETE)] ON [dbo].[BLACK_LIST_REG] ([DISTR] ASC, [ID_SYS] ASC, [COMP] ASC, [P_DELETE] ASC);
GO
