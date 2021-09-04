USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillFactDetailTable]
(
        [BFD_ID]           bigint          Identity(1,1)   NOT NULL,
        [BFD_ID_BFM]       bigint                          NOT NULL,
        [CO_NUM]           VarChar(100)                        NULL,
        [CO_DATE]          SmallDateTime                       NULL,
        [BILL_STR]         VarChar(150)                    NOT NULL,
        [TX_PERCENT]       decimal                         NOT NULL,
        [TX_NAME]          VarChar(50)                     NOT NULL,
        [SYS_NAME]         VarChar(250)                    NOT NULL,
        [SYS_ORDER]        SmallInt                            NULL,
        [DIS_ID]           Int                                 NULL,
        [DIS_NUM]          VarChar(20)                     NOT NULL,
        [PR_ID]            SmallInt                        NOT NULL,
        [PR_MONTH]         VarChar(50)                     NOT NULL,
        [PR_DATE]          SmallDateTime                   NOT NULL,
        [BD_UNPAY]         Money                           NOT NULL,
        [BD_TAX_UNPAY]     Money                           NOT NULL,
        [BD_TOTAL_UNPAY]   Money                           NOT NULL,
        CONSTRAINT [PK_dbo.BillFactDetailTable] PRIMARY KEY NONCLUSTERED ([BFD_ID]),
        CONSTRAINT [FK_dbo.BillFactDetailTable(BFD_ID_BFM)_dbo.BillFactMasterTable(BFM_ID)] FOREIGN KEY  ([BFD_ID_BFM]) REFERENCES [dbo].[BillFactMasterTable] ([BFM_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.BillFactDetailTable(BFD_ID_BFM)] ON [dbo].[BillFactDetailTable] ([BFD_ID_BFM] ASC);
GO
