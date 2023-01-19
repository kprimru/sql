USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ric_Art]
(
        [ID]           Int                NOT NULL,
        [TO_NAME]      VarChar(255)           NULL,
        [TO_INN]       VarChar(50)            NULL,
        [TO_PRICE_3]   Money                  NULL,
        [TO_PRICE_4]   Money                  NULL,
        [TO_PRICE_5]   Money                  NULL,
        [COMMENTS]     NVarChar(510)          NULL,
        CONSTRAINT [PK_dbo.Ric_Art] PRIMARY KEY CLUSTERED ([ID])
);
GO
