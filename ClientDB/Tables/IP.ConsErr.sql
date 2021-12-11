USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IP].[ConsErr]
(
        [SYS]     SmallInt      NOT NULL,
        [DISTR]   Int           NOT NULL,
        [COMP]    TinyInt       NOT NULL,
        [DATE]    DateTime      NOT NULL,
        CONSTRAINT [PK_IP.ConsErr] PRIMARY KEY CLUSTERED ([SYS],[DISTR],[COMP])
);
GO
