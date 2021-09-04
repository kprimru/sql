USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBFBill]
(
        [ID]               bigint          Identity(1,1)   NOT NULL,
        [SYS_REG_NAME]     NVarChar(128)                   NOT NULL,
        [DIS_NUM]          Int                             NOT NULL,
        [DIS_COMP_NUM]     TinyInt                         NOT NULL,
        [PR_DATE]          SmallDateTime                   NOT NULL,
        [BD_TOTAL_PRICE]   Money                           NOT NULL,
        CONSTRAINT [PK_dbo.DBFBill] PRIMARY KEY NONCLUSTERED ([ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.DBFBill(DIS_NUM,SYS_REG_NAME,DIS_COMP_NUM,PR_DATE)] ON [dbo].[DBFBill] ([DIS_NUM] ASC, [SYS_REG_NAME] ASC, [DIS_COMP_NUM] ASC, [PR_DATE] ASC);
GO
