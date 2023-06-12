USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBFBillRest]
(
        [ID]             bigint        Identity(1,1)   NOT NULL,
        [SYS_REG_NAME]   VarChar(50)                   NOT NULL,
        [DIS_NUM]        Int                           NOT NULL,
        [DIS_COMP_NUM]   TinyInt                       NOT NULL,
        [PR_DATE]        DateTime                      NOT NULL,
        [BD_REST]        Money                             NULL,
        CONSTRAINT [PK_dbo.DBFBillRest] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.DBFBillRest(DIS_NUM,PR_DATE,SYS_REG_NAME,DIS_COMP_NUM)] ON [dbo].[DBFBillRest] ([DIS_NUM] ASC, [PR_DATE] ASC, [SYS_REG_NAME] ASC, [DIS_COMP_NUM] ASC);
GO
