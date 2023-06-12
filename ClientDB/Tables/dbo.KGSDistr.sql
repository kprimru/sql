USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KGSDistr]
(
        [KD_ID]        Int       Identity(1,1)   NOT NULL,
        [KD_ID_LIST]   Int                       NOT NULL,
        [KD_ID_SYS]    Int                       NOT NULL,
        [KD_DISTR]     Int                       NOT NULL,
        [KD_COMP]      TinyInt                   NOT NULL,
        CONSTRAINT [PK_dbo.KGSDistr] PRIMARY KEY CLUSTERED ([KD_ID]),
        CONSTRAINT [FK_dbo.KGSDistr(KD_ID_SYS)_dbo.SystemTable(SystemID)] FOREIGN KEY  ([KD_ID_SYS]) REFERENCES [dbo].[SystemTable] ([SystemID]),
        CONSTRAINT [FK_dbo.KGSDistr(KD_ID_LIST)_dbo.KGSDistrList(KDL_ID)] FOREIGN KEY  ([KD_ID_LIST]) REFERENCES [dbo].[KGSDistrList] ([KDL_ID])
);
GO
