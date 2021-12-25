USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NetType]
(
        [NT_ID]          SmallInt       Identity(1,1)   NOT NULL,
        [NT_SHORT]       VarChar(50)                    NOT NULL,
        [NT_NAME]        VarChar(150)                   NOT NULL,
        [NT_NET]         SmallInt                       NOT NULL,
        [NT_TECH]        SmallInt                       NOT NULL,
        [NT_VMI_GROUP]   VarChar(50)                    NOT NULL,
        [NT_ACTIVE]      Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.NetType] PRIMARY KEY CLUSTERED ([NT_ID])
);GO
