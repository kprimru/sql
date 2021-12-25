USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceTypeSystemTable]
(
        [PTS_ID]       SmallInt   Identity(1,1)   NOT NULL,
        [PTS_ID_PT]    SmallInt                   NOT NULL,
        [PTS_ID_ST]    SmallInt                   NOT NULL,
        [PTS_ACTIVE]   Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.PriceTypeSystemTable] PRIMARY KEY CLUSTERED ([PTS_ID]),
        CONSTRAINT [FK_dbo.PriceTypeSystemTable(PTS_ID_PT)_dbo.PriceTypeTable(PT_ID)] FOREIGN KEY  ([PTS_ID_PT]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID]),
        CONSTRAINT [FK_dbo.PriceTypeSystemTable(PTS_ID_ST)_dbo.SystemTypeTable(SST_ID)] FOREIGN KEY  ([PTS_ID_ST]) REFERENCES [dbo].[SystemTypeTable] ([SST_ID])
);GO
