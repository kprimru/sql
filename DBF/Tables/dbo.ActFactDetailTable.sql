USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActFactDetailTable]
(
        [AFD_ID]           bigint          Identity(1,1)   NOT NULL,
        [AFD_ID_AFM]       bigint                          NOT NULL,
        [PR_ID]            SmallInt                        NOT NULL,
        [PR_DATE]          SmallDateTime                   NOT NULL,
        [PR_MONTH]         VarChar(50)                     NOT NULL,
        [PR_END_DATE]      SmallDateTime                   NOT NULL,
        [DIS_ID]           Int                             NOT NULL,
        [DIS_NUM]          VarChar(50)                     NOT NULL,
        [SYS_NAME]         VarChar(250)                    NOT NULL,
        [SYS_ORDER]        Int                             NOT NULL,
        [AD_PRICE]         Money                           NOT NULL,
        [AD_TAX_PRICE]     Money                           NOT NULL,
        [AD_TOTAL_PRICE]   Money                           NOT NULL,
        [TX_PERCENT]       decimal                         NOT NULL,
        [TX_NAME]          VarChar(50)                     NOT NULL,
        [SO_ID]            SmallInt                        NOT NULL,
        [SO_BILL_STR]      VarChar(150)                    NOT NULL,
        [SO_INV_UNIT]      VarChar(150)                        NULL,
        [AD_PAYED_PRICE]   Money                           NOT NULL,
        [TO_NUM]           Int                                 NULL,
        [TO_NAME]          VarChar(255)                        NULL,
        [SYS_ADD]          VarChar(512)                        NULL,
        CONSTRAINT [PK_dbo.ActFactDetailTable] PRIMARY KEY CLUSTERED ([AFD_ID]),
        CONSTRAINT [FK_dbo.ActFactDetailTable(AFD_ID_AFM)_dbo.ActFactMasterTable(AFM_ID)] FOREIGN KEY  ([AFD_ID_AFM]) REFERENCES [dbo].[ActFactMasterTable] ([AFM_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ActFactDetailTable(AFD_ID_AFM)+(AD_TOTAL_PRICE)] ON [dbo].[ActFactDetailTable] ([AFD_ID_AFM] ASC) INCLUDE ([AD_TOTAL_PRICE]);
GO
