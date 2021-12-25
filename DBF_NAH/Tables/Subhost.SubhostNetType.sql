USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostNetType]
(
        [SNT_ID]           Int           Identity(1,1)   NOT NULL,
        [SNT_ID_PERIOD]    SmallInt                      NOT NULL,
        [SNT_ID_SUBHOST]   SmallInt                      NOT NULL,
        [SNT_TYPE]         VarChar(20)                   NOT NULL,
        [ID]               Int                               NULL,
        [TITLE]            VarChar(50)                   NOT NULL,
        [SN_ID]            SmallInt                          NULL,
        [TT_ID]            SmallInt                          NULL,
        [SN_SOURCE]        SmallInt                          NULL,
        [SN_DEST]          SmallInt                          NULL,
        [COEF]             decimal                           NULL,
        [COEF_OLD]         decimal                           NULL,
        [COEF_NEW]         decimal                           NULL,
        CONSTRAINT [PK_Subhost.SubhostNetType] PRIMARY KEY CLUSTERED ([SNT_ID])
);GO
