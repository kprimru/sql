USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[TechTypeDetail]
(
        [TT_ID]          UniqueIdentifier      NOT NULL,
        [TT_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [TT_NAME]        VarChar(50)           NOT NULL,
        [TT_SHORT]       VarChar(50)               NULL,
        [TT_REG]         Int                   NOT NULL,
        [TT_COEF]        decimal               NOT NULL,
        [TT_DATE]        SmallDateTime         NOT NULL,
        [TT_END]         SmallDateTime             NULL,
        [TT_REF]         TinyInt               NOT NULL,
        [TT_WEIGHT]      decimal                   NULL,
        CONSTRAINT [PK_TechType] PRIMARY KEY CLUSTERED ([TT_ID]),
        CONSTRAINT [FK_TechType_TechType] FOREIGN KEY  ([TT_ID_MASTER]) REFERENCES [Distr].[TechType] ([TTMS_ID])
);GO
