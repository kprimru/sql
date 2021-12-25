USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[Diu]
(
        [DIU_ID]           Int             Identity(1,1)   NOT NULL,
        [DIU_ID_SYSTEM]    SmallInt                        NOT NULL,
        [DIU_DISTR]        Int                             NOT NULL,
        [DIU_COMP]         TinyInt                         NOT NULL,
        [DIU_ID_SUBHOST]   SmallInt                        NOT NULL,
        [DIU_DATE]         SmallDateTime                       NULL,
        [DIU_LAST]         SmallDateTime                       NULL,
        [DIU_ACTIVE]       Bit                             NOT NULL,
        CONSTRAINT [PK_Subhost.Diu] PRIMARY KEY CLUSTERED ([DIU_ID]),
        CONSTRAINT [FK_Subhost.Diu(DIU_ID_SYSTEM)_Subhost.SystemTable(SYS_ID)] FOREIGN KEY  ([DIU_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID]),
        CONSTRAINT [FK_Subhost.Diu(DIU_ID_SUBHOST)_Subhost.SubhostTable(SH_ID)] FOREIGN KEY  ([DIU_ID_SUBHOST]) REFERENCES [dbo].[SubhostTable] ([SH_ID])
);GO
