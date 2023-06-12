USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DistrExceptTable]
(
        [DE_ID]          Int            Identity(1,1)   NOT NULL,
        [DE_ID_SYSTEM]   SmallInt                       NOT NULL,
        [DE_DIS_NUM]     Int                            NOT NULL,
        [DE_COMP_NUM]    TinyInt                        NOT NULL,
        [DE_COMMENT]     VarChar(250)                   NOT NULL,
        [DE_ACTIVE]      Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.DistrExceptTable] PRIMARY KEY CLUSTERED ([DE_ID]),
        CONSTRAINT [FK_dbo.DistrExceptTable(DE_ID_SYSTEM)_dbo.SystemTable(SYS_ID)] FOREIGN KEY  ([DE_ID_SYSTEM]) REFERENCES [dbo].[SystemTable] ([SYS_ID])
);
GO
