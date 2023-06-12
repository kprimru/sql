USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[RegNode]
(
        [RN_SYSTEM]      VarChar(50)        NOT NULL,
        [RN_DISTR]       Int                NOT NULL,
        [RN_COMP]        TinyInt            NOT NULL,
        [RN_TYPE]        VarChar(20)        NOT NULL,
        [RN_TECH]        TinyInt            NOT NULL,
        [RN_NET_COUNT]   SmallInt           NOT NULL,
        [RN_SUBHOST]     TinyInt            NOT NULL,
        [RN_TRANSFER]    SmallInt           NOT NULL,
        [RN_LEFT]        SmallInt           NOT NULL,
        [RN_STATUS]      SmallInt           NOT NULL,
        [RN_DATE]        SmallDateTime          NULL,
        [RN_COMMENT]     VarChar(255)           NULL,
        [RN_COMPLECT]    VarChar(50)            NULL,
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_Common.RegNode(RN_DISTR,RN_SYSTEM,RN_COMP)] ON [Common].[RegNode] ([RN_DISTR] ASC, [RN_SYSTEM] ASC, [RN_COMP] ASC);
GO
