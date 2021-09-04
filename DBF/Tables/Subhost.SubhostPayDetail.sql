USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostPayDetail]
(
        [SPD_ID]          Int        Identity(1,1)   NOT NULL,
        [SPD_ID_PAY]      Int                        NOT NULL,
        [SPD_ID_PERIOD]   SmallInt                   NOT NULL,
        [SPD_SUM]         Money                      NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostPayDetail] PRIMARY KEY CLUSTERED ([SPD_ID]),
        CONSTRAINT [FK_Subhost.SubhostPayDetail(SPD_ID_PAY)_Subhost.SubhostPay(SHP_ID)] FOREIGN KEY  ([SPD_ID_PAY]) REFERENCES [Subhost].[SubhostPay] ([SHP_ID]),
        CONSTRAINT [FK_Subhost.SubhostPayDetail(SPD_ID_PERIOD)_Subhost.PeriodTable(PR_ID)] FOREIGN KEY  ([SPD_ID_PERIOD]) REFERENCES [dbo].[PeriodTable] ([PR_ID])
);GO
