USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientTypeTable]
(
        [CLT_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [CLT_NAME]     VarChar(100)                   NOT NULL,
        [CLT_PSEDO]    VarChar(20)                    NOT NULL,
        [CLT_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.ClientTypeTable] PRIMARY KEY CLUSTERED ([CLT_ID])
);
GO
