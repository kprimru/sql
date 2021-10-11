USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ric_Ussur]
(
        [ID]           Int                   NULL,
        [TO_NAME]      VarChar(255)          NULL,
        [TO_INN]       VarChar(50)           NULL,
        [TO_NUM_3]     VarChar(255)          NULL,
        [TO_PRICE_3]   Money                 NULL,
        [TO_NUM_4]     VarChar(255)          NULL,
        [TO_PRICE_4]   Money                 NULL,
        [TO_NUM_5]     VarChar(255)          NULL,
        [TO_PRICE_5]   Money                 NULL,
);GO
