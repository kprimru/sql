USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReturnCode]
(
        [RC_ID]        Int            Identity(1,1)   NOT NULL,
        [RC_NUM]       Int                            NOT NULL,
        [RC_TEXT]      VarChar(150)                   NOT NULL,
        [RC_TYPE]      VarChar(20)                    NOT NULL,
        [RC_ERROR]     Bit                                NULL,
        [RC_WARNING]   Bit                                NULL,
        CONSTRAINT [PK_dbo.ReturnCode] PRIMARY KEY CLUSTERED ([RC_ID])
);GO
