USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PayCoefTable]
(
        [PC_ID]       SmallInt   Identity(1,1)   NOT NULL,
        [PC_START]    SmallInt                   NOT NULL,
        [PC_END]      SmallInt                   NOT NULL,
        [PC_VALUE]    decimal                    NOT NULL,
        [PC_ACTIVE]   Bit                        NOT NULL,
        CONSTRAINT [PK_dbo.PayCoefTable] PRIMARY KEY CLUSTERED ([PC_ID])
);GO
