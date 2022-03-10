USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Distr].[SystemTypeWeight]
(
        [STW_ID]          UniqueIdentifier      NOT NULL,
        [STW_ID_SYSTEM]   UniqueIdentifier      NOT NULL,
        [STW_ID_TYPE]     UniqueIdentifier      NOT NULL,
        [STW_WEIGHT]      Int                       NULL,
        CONSTRAINT [PK_Distr.SystemTypeWeight] PRIMARY KEY CLUSTERED ([STW_ID])
);GO
