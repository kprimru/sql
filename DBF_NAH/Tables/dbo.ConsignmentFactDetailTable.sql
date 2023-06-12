USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsignmentFactDetailTable]
(
        [CFD_ID]               bigint         Identity(1,1)   NOT NULL,
        [CFD_ID_CFM]           bigint                             NULL,
        [CSD_NUM]              Int                                NULL,
        [CSD_NAME]             VarChar(150)                       NULL,
        [CSD_STR]              VarChar(150)                       NULL,
        [DIS_ID]               Int                                NULL,
        [DIS_STR]              VarChar(50)                        NULL,
        [CSD_CODE]             VarChar(50)                        NULL,
        [CSD_UNIT]             VarChar(100)                       NULL,
        [CSD_OKEI]             VarChar(50)                        NULL,
        [CSD_PACKING]          VarChar(50)                        NULL,
        [CSD_COUNT_IN_PLACE]   VarChar(50)                        NULL,
        [CSD_PLACE]            VarChar(50)                        NULL,
        [CSD_MASS]             VarChar(50)                        NULL,
        [CSD_COUNT]            SmallInt                           NULL,
        [CSD_COST]             Money                              NULL,
        [CSD_PRICE]            Money                              NULL,
        [CSD_TAX_PRICE]        Money                              NULL,
        [CSD_TOTAL_PRICE]      Money                              NULL,
        [CSD_PAYED_PRICE]      Money                              NULL,
        [TX_PERCENT]           decimal                            NULL,
        [TX_NAME]              VarChar(50)                        NULL,
        CONSTRAINT [PK_dbo.ConsignmentFactDetailTable] PRIMARY KEY NONCLUSTERED ([CFD_ID]),
        CONSTRAINT [FK_dbo.ConsignmentFactDetailTable(CFD_ID_CFM)_dbo.ConsignmentFactMasterTable(CFM_ID)] FOREIGN KEY  ([CFD_ID_CFM]) REFERENCES [dbo].[ConsignmentFactMasterTable] ([CFM_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ConsignmentFactDetailTable(CFD_ID_CFM,CFD_ID)] ON [dbo].[ConsignmentFactDetailTable] ([CFD_ID_CFM] ASC, [CFD_ID] ASC);
GO
