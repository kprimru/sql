USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubhostType]
(
        [ST_ID]       TinyInt        Identity(1,1)   NOT NULL,
        [ST_CODE]     VarChar(50)                        NULL,
        [ST_NAME]     VarChar(100)                       NULL,
        [ST_ACTIVE]   Bit                                NULL,
        CONSTRAINT [PK_SubhostType] PRIMARY KEY CLUSTERED ([ST_ID])
);GO
