USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceTable]
(
        [PP_ID]         SmallInt      Identity(1,1)   NOT NULL,
        [PP_NAME]       VarChar(50)                   NOT NULL,
        [PP_ID_TYPE]    SmallInt                      NOT NULL,
        [PP_COEF_MUL]   numeric                       NOT NULL,
        [PP_COEF_ADD]   Money                         NOT NULL,
        [PP_ACTIVE]     Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.PriceTable] PRIMARY KEY CLUSTERED ([PP_ID]),
        CONSTRAINT [FK_dbo.PriceTable(PP_ID_TYPE)_dbo.PriceTypeTable(PT_ID)] FOREIGN KEY  ([PP_ID_TYPE]) REFERENCES [dbo].[PriceTypeTable] ([PT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.PriceTable()] ON [dbo].[PriceTable] ([PP_NAME] ASC);
GO
