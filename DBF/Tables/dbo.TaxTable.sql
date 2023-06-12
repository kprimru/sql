USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxTable]
(
        [TX_ID]        SmallInt       Identity(1,1)   NOT NULL,
        [TX_NAME]      VarChar(100)                   NOT NULL,
        [TX_PERCENT]   decimal                        NOT NULL,
        [TX_CAPTION]   VarChar(50)                        NULL,
        [TX_ACTIVE]    Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.TaxTable] PRIMARY KEY CLUSTERED ([TX_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.TaxTable(TX_CAPTION)] ON [dbo].[TaxTable] ([TX_CAPTION] ASC);
CREATE UNIQUE NONCLUSTERED INDEX [UX_dbo.TaxTable(TX_PERCENT)] ON [dbo].[TaxTable] ([TX_PERCENT] ASC);
GO
