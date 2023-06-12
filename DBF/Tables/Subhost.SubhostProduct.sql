USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Subhost].[SubhostProduct]
(
        [SP_ID]         SmallInt       Identity(1,1)   NOT NULL,
        [SP_ID_GROUP]   SmallInt                       NOT NULL,
        [SP_NAME]       VarChar(100)                   NOT NULL,
        [SP_ID_UNIT]    SmallInt                       NOT NULL,
        [SP_COEF]       decimal                            NULL,
        [SP_ACTIVE]     Bit                            NOT NULL,
        CONSTRAINT [PK_Subhost.SubhostProduct] PRIMARY KEY CLUSTERED ([SP_ID]),
        CONSTRAINT [FK_Subhost.SubhostProduct(SP_ID_UNIT)_Subhost.UnitTable(UN_ID)] FOREIGN KEY  ([SP_ID_UNIT]) REFERENCES [dbo].[UnitTable] ([UN_ID]),
        CONSTRAINT [FK_Subhost.SubhostProduct(SP_ID_GROUP)_Subhost.SubhostProductGroup(SPG_ID)] FOREIGN KEY  ([SP_ID_GROUP]) REFERENCES [Subhost].[SubhostProductGroup] ([SPG_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Subhost.SubhostProduct(SP_ID_GROUP,SP_NAME)] ON [Subhost].[SubhostProduct] ([SP_ID_GROUP] ASC, [SP_NAME] ASC);
GO
