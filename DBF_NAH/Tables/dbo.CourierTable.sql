USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourierTable]
(
        [COUR_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [COUR_NAME]       VarChar(150)                   NOT NULL,
        [COUR_ID_TYPE]    SmallInt                           NULL,
        [COUR_ID_CITY]    SmallInt                           NULL,
        [COUR_ACTIVE]     Bit                            NOT NULL,
        [COUR_OLD_CODE]   Int                                NULL,
        CONSTRAINT [PK_dbo.CourierTable] PRIMARY KEY CLUSTERED ([COUR_ID]),
        CONSTRAINT [FK_dbo.CourierTable(COUR_ID_TYPE)_dbo.CourierTypeTable(COT_ID)] FOREIGN KEY  ([COUR_ID_TYPE]) REFERENCES [dbo].[CourierTypeTable] ([COT_ID]),
        CONSTRAINT [FK_dbo.CourierTable(COUR_ID_CITY)_dbo.CityTable(CT_ID)] FOREIGN KEY  ([COUR_ID_CITY]) REFERENCES [dbo].[CityTable] ([CT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.CourierTable(COUR_NAME)] ON [dbo].[CourierTable] ([COUR_NAME] ASC);
GO
