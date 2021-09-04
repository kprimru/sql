USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Price].[PriceDepend]
(
        [ID]                Int        Identity(1,1)   NOT NULL,
        [ID_OLD_PRICE]      SmallInt                   NOT NULL,
        [ID_NEW_PRICE]      SmallInt                   NOT NULL,
        [ID_OLD_SYS_TYPE]   SmallInt                   NOT NULL,
        [ID_NEW_SYS_TYPE]   SmallInt                   NOT NULL,
        [ID_OLD_NET]        SmallInt                   NOT NULL,
        [ID_NEW_NET]        SmallInt                   NOT NULL,
        [COEF]              decimal                    NOT NULL,
        CONSTRAINT [PK_Price.PriceDepend] PRIMARY KEY CLUSTERED ([ID])
);GO
