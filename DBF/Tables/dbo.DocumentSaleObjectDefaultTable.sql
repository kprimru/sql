USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentSaleObjectDefaultTable]
(
        [DSD_ID]        SmallInt   Identity(1,1)   NOT NULL,
        [DSD_ID_SO]     SmallInt                   NOT NULL,
        [DSD_ID_DOC]    SmallInt                   NOT NULL,
        [DSD_ID_GOOD]   SmallInt                   NOT NULL,
        [DSD_ID_UNIT]   SmallInt                   NOT NULL,
        [DSD_PRINT]     Bit                        NOT NULL,
        [DSD_ACTIVE]    Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.DocumentSaleObjectDefaultTable] PRIMARY KEY CLUSTERED ([DSD_ID]),
        CONSTRAINT [FK_dbo.DocumentSaleObjectDefaultTable(DSD_ID_SO)_dbo.SaleObjectTable(SO_ID)] FOREIGN KEY  ([DSD_ID_SO]) REFERENCES [dbo].[SaleObjectTable] ([SO_ID]),
        CONSTRAINT [FK_dbo.DocumentSaleObjectDefaultTable(DSD_ID_DOC)_dbo.DocumentTable(DOC_ID)] FOREIGN KEY  ([DSD_ID_DOC]) REFERENCES [dbo].[DocumentTable] ([DOC_ID]),
        CONSTRAINT [FK_dbo.DocumentSaleObjectDefaultTable(DSD_ID_UNIT)_dbo.UnitTable(UN_ID)] FOREIGN KEY  ([DSD_ID_UNIT]) REFERENCES [dbo].[UnitTable] ([UN_ID]),
        CONSTRAINT [FK_dbo.DocumentSaleObjectDefaultTable(DSD_ID_GOOD)_dbo.GoodTable(GD_ID)] FOREIGN KEY  ([DSD_ID_GOOD]) REFERENCES [dbo].[GoodTable] ([GD_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.DocumentSaleObjectDefaultTable(DSD_ID_DOC,DSD_ID_SO)] ON [dbo].[DocumentSaleObjectDefaultTable] ([DSD_ID_DOC] ASC, [DSD_ID_SO] ASC);
GO
