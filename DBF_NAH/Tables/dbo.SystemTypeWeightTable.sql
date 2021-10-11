USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemTypeWeightTable]
(
        [STW_ID]          Int        Identity(1,1)   NOT NULL,
        [STW_ID_SYSTEM]   SmallInt                   NOT NULL,
        [STW_ID_TYPE]     SmallInt                   NOT NULL,
        [STW_WEIGHT]      SmallInt                   NOT NULL,
        [STW_ACTIVE]      Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.SystemTypeWeightTable] PRIMARY KEY CLUSTERED ([STW_ID]),
        CONSTRAINT [FK_dbo.SystemTypeWeightTable(STW_ID_TYPE)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([STW_ID_TYPE]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID]),
        CONSTRAINT [FK_dbo.SystemTypeWeightTable(STW_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([STW_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);GO
