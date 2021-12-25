USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quarter]
(
        [QR_ID]       SmallInt        Identity(1,1)   NOT NULL,
        [QR_NAME]     VarChar(50)                     NOT NULL,
        [QR_BEGIN]    SmallDateTime                   NOT NULL,
        [QR_END]      SmallDateTime                   NOT NULL,
        [QR_ACTIVE]   Bit                             NOT NULL,
        CONSTRAINT [PK_dbo.Quarter] PRIMARY KEY CLUSTERED ([QR_ID])
);GO
