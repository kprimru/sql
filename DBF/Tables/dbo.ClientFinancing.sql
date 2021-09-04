USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientFinancing]
(
        [ID]                  Int            Identity(1,1)   NOT NULL,
        [ID_CLIENT]           Int                            NOT NULL,
        [BILL_GROUP]          Bit                            NOT NULL,
        [BILL_MASS_PRINT]     Bit                            NOT NULL,
        [UNKNOWN_FINANCING]   Bit                                NULL,
        [EIS_CODE]            VarChar(256)                       NULL,
        [UPD_PRINT]           Bit                            NOT NULL,
        [EIS_DATA]            xml                                NULL,
        [EIS_CONTRACT]        VarChar(100)                       NULL,
        [EIS_REG_NUM]         VarChar(100)                       NULL,
        [EIS_LINK]            VarChar(512)                       NULL,
        CONSTRAINT [PK_dbo.ClientFinancing] PRIMARY KEY NONCLUSTERED ([ID]),
        CONSTRAINT [FK_dbo.ClientFinancing(ID_CLIENT)_dbo.ClientTable(CL_ID)] FOREIGN KEY  ([ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([CL_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientFinancing(ID)] ON [dbo].[ClientFinancing] ([ID] ASC);
GO
